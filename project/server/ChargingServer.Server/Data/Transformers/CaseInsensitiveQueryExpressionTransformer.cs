using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;
using System.Reflection;

namespace ChargingServer.Server.Data.Transformers
{
    public sealed class CaseInsensitiveQueryExpressionTransformer : IQueryExpressionInterceptor
    {
        private static readonly ExpressionVisitor[] _transformers = [
                new StringMethodTransformer(),
        ];

        public Expression QueryCompilationStarting(Expression queryExpression, QueryExpressionEventData eventData)
        {
            foreach (var transformer in _transformers)
            {
                queryExpression = transformer.Visit(queryExpression);
            }
            return queryExpression;
        }
        //
        // We want to transform string comparison methods to be case insensitive.
        //
        // From:
        // .Where(x => x.Name.IndexOf(searchTerm) > 0)
        // --WHERE strpos(p."Name", 'csharp') > 0
        //
        // To:
        // .Where(x => EF.Functions.Collate(x.Name.ToLower(), "default").IndexOf(searchTerm.ToLower()) > 0)
        // --WHERE strpos(LOWER(p."Name") COLLATE "default", LOWER(@searchTerm)) > 0
        //
        private sealed class StringMethodTransformer : ExpressionVisitor
        {
            private static readonly string _defaultCollation = "default";
            // https://github.com/npgsql/efcore.pg/blob/main/src/EFCore.PG/Query/ExpressionTranslators/Internal/NpgsqlStringMethodTranslator.cs
            private static readonly MethodInfo _indexOfCharMethod = typeof(string).GetRuntimeMethod(nameof(string.IndexOf), [typeof(char)])!;
            private static readonly MethodInfo _indexOfStringMethod = typeof(string).GetRuntimeMethod(nameof(string.IndexOf), [typeof(string)])!;
            private static readonly MethodInfo _startsWithStringMethod = typeof(string).GetRuntimeMethod(nameof(string.StartsWith), [typeof(string)])!;
            private static readonly MethodInfo _endsWithStringMethod = typeof(string).GetRuntimeMethod(nameof(string.EndsWith), [typeof(string)])!;
            private static readonly MethodInfo _containsStringMethod = typeof(string).GetRuntimeMethod(nameof(string.Contains), [typeof(string)])!;
            private static readonly MethodInfo _replaceCharMethod = typeof(string).GetRuntimeMethod(nameof(string.Replace), [typeof(char), typeof(char)])!;
            private static readonly MethodInfo _replaceStringMethod = typeof(string).GetRuntimeMethod(nameof(string.Replace), [typeof(string), typeof(string)])!;
            private static readonly MethodInfo _charToStringMethod = typeof(char).GetRuntimeMethod(nameof(char.ToString), [])!;
            private static readonly MethodInfo _stringToLowerMethod = typeof(string).GetRuntimeMethod(nameof(string.ToLower), [])!;
            private static readonly MethodInfo _collateMethod = typeof(RelationalDbFunctionsExtensions).GetMethod(nameof(RelationalDbFunctionsExtensions.Collate))!;
            protected override Expression VisitMethodCall(MethodCallExpression node)
            {
                var method = node.Method;
                if (method == _indexOfCharMethod)
                {
                    var target = node.Object!;
                    var argument = CharToString(node.Arguments[0]);
                    node = Transform(_indexOfCharMethod, target, argument);
                }
                else if (method == _indexOfStringMethod)
                {
                    var target = node.Object!;
                    var argument = node.Arguments[0];
                    node = Transform(_indexOfStringMethod, target, argument);
                }
                if (method == _startsWithStringMethod)
                {
                    var target = node.Object!;
                    var argument = node.Arguments[0];
                    node = Transform(_startsWithStringMethod, target, argument);
                }
                else if (method == _endsWithStringMethod)
                {
                    var target = node.Object!;
                    var argument = node.Arguments[0];
                    node = Transform(_endsWithStringMethod, target, argument);
                }
                else if (method == _containsStringMethod)
                {
                    var target = node.Object!;
                    var argument = node.Arguments[0];
                    node = Transform(_containsStringMethod, target, argument);
                }
                else if (method == _replaceCharMethod)
                {
                    var target = node.Object!;
                    var argument1 = node.Arguments[0];
                    var argument2 = node.Arguments[1];
                    node = Transform(_replaceCharMethod, target, argument1, argument2);
                }
                else if (method == _replaceStringMethod)
                {
                    var target = node.Object!;
                    var argument1 = node.Arguments[0];
                    var argument2 = node.Arguments[1];
                    node = Transform(_replaceStringMethod, target, argument1, argument2);
                }
                return base.VisitMethodCall(node);
            }
            private static MethodCallExpression Transform(
                MethodInfo targetMethod, Expression target, params Expression[] arguments)
            {
                var targetToLower = ToLower(target);
                var targetCollate = Collate(targetToLower);
                var finalArguments = new List<Expression>(arguments.Length);
                foreach (var argument in arguments)
                {
                    finalArguments.Add(ToLower(argument));
                }
                return Expression.Call(targetCollate, targetMethod, finalArguments);
            }
            private static MethodCallExpression ToLower(Expression target) =>
                Expression.Call(target, _stringToLowerMethod);
            private static MethodCallExpression CharToString(Expression target) =>
                Expression.Call(target, _charToStringMethod);
            private static MethodCallExpression Collate(Expression target) =>
                Expression.Call(
                    null,
                    _collateMethod.MakeGenericMethod(target.Type),
                    Expression.Constant(EF.Functions),
                    target,
                    Expression.Constant(_defaultCollation));
        }
    }
}

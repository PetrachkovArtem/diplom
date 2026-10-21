namespace ChargingServer.Server.Logs;

public static class FileLoggerExtensions
{
    public static ILoggingBuilder AddFile(this ILoggingBuilder builder, Dictionary<string, LogCategoryDesc> descs)
    {
        builder.AddProvider(new FileLoggerProvider(descs));
        return builder;
    }
}

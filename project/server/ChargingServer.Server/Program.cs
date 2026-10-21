using ChargingServer.Ocpp;
using ChargingServer.Ocpp.Abstractions;
using ChargingServer.Server.Data;
using ChargingServer.Server.Data.Entities;
using ChargingServer.Server.Data.Transformers;
using ChargingServer.Server.Hubs;
using ChargingServer.Server.Logs;
using ChargingServer.Server.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

var logsDir = Path.Combine(Directory.GetCurrentDirectory(), "logs");
Directory.CreateDirectory(logsDir);

var minLogLevel = LogLevel.Warning;
Enum.TryParse(builder.Configuration["Logging:LogLevel:Custom"], ignoreCase: true, out minLogLevel);

builder.Logging.AddFile(new Dictionary<string, LogCategoryDesc>
{
    ["Default"] = new LogCategoryDesc
    {
        Path = Path.Combine(logsDir, "log.log"),
        LogLevel = minLogLevel
    },
    ["OccpLogger"] = new LogCategoryDesc
    {
        Path = Path.Combine(logsDir, "requests.log"),
        LogLevel = LogLevel.Information
    }
});

builder.Services.AddControllers(cfg =>
{
    var policy = new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build();
    cfg.Filters.Add(new AuthorizeFilter(policy));
});

builder.Services.AddOpenApi();
builder.Services.AddHttpContextAccessor();
builder.Services.AddSignalR();

builder.Services.AddSingleton<CaseInsensitiveQueryExpressionTransformer>();
builder.Services.AddDbContext<AppDbContext>((sp, options) =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("Default"));
    options.AddInterceptors(sp.GetRequiredService<CaseInsensitiveQueryExpressionTransformer>());
});


builder.Services.AddOcppProtocol();
builder.Services.AddSingleton<IPasswordHasher<AccountEntity>, PasswordHasher<AccountEntity>>();
builder.Services.AddScoped<IOcppHandler, OcppHandler>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<StationService>();
builder.Services.AddScoped<SessionService>();
builder.Services.AddScoped<AdminService>();

var jwtKey = builder.Configuration["Jwt:Key"] ?? "skdjIOqqeijweJYydghjkLKJHuyaygBNMMJDHajshdjada";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"] ?? "ChargingServer",
            ValidAudience = builder.Configuration["Jwt:Audience"] ?? "ChargingServer",
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            RoleClaimType = System.Security.Claims.ClaimTypes.Role,
            NameClaimType = System.Security.Claims.ClaimTypes.NameIdentifier
        };

        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;
                if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
                {
                    context.Token = accessToken;
                }

                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy => policy.AllowAnyHeader().AllowAnyMethod().AllowCredentials().SetIsOriginAllowed(_ => true));
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    var passwordHasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher<AccountEntity>>();
    await DbSeeder.SeedAsync(db, app.Configuration, passwordHasher);
}

app.UseDefaultFiles();
app.MapStaticAssets();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors();
app.UseWebSockets();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<SessionHub>("/hubs/session");
app.MapFallbackToFile("/index.html");

app.Run();

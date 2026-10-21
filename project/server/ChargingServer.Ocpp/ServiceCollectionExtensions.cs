using ChargingServer.Ocpp.Handlers;
using ChargingServer.Ocpp.Transport;
using Microsoft.Extensions.DependencyInjection;

namespace ChargingServer.Ocpp;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddOcppProtocol(this IServiceCollection services)
    {
        services.AddSingleton<OcppConnectionStore>();
        services.AddSingleton<OcppWebSocketService>();
        services.AddSingleton<OcppMessageSender>();
        services.AddScoped<OcppMessageHandlerFactory>();
        return services;
    }
}

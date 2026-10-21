using System.Net.WebSockets;
using ChargingServer.Ocpp.Models.Messages;

namespace ChargingServer.Ocpp.Abstractions;

public interface IOcppHandler
{
    Task<BootNotificationResponse> HandleBootNotificationAsync(string bindToken, string chargePointId, BootNotificationRequest request, CancellationToken cancellationToken = default);
    Task HandleStatusNotificationAsync(string chargePointId, StatusNotificationRequest request, CancellationToken cancellationToken = default);
    Task HandleTransactionEventAsync(string chargePointId, TransactionEventRequest request, CancellationToken cancellationToken = default);
    Task HandleConnectionOpenedAsync(string chargePointId, CancellationToken cancellationToken = default);
    Task HandleConnectionClosedAsync(string chargePointId, WebSocket? closingSocket = null, CancellationToken cancellationToken = default);
    Task LogMessageAsync(string? chargePointId, string direction, string action, string payload, CancellationToken cancellationToken = default);
}

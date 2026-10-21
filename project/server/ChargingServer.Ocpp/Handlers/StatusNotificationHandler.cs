using System.Net.WebSockets;
using System.Text.Json;
using ChargingServer.Ocpp.Abstractions;
using ChargingServer.Ocpp.Json;
using ChargingServer.Ocpp.Models.Messages;
using Microsoft.Extensions.Logging;

namespace ChargingServer.Ocpp.Handlers;

public class StatusNotificationHandler(string messageId, ILogger logger, IOcppHandler domain) : WithResponseHandler(messageId, true, logger)
{
    private readonly IOcppHandler _handler = domain;

    public override async Task ProcessAsync(WebSocket webSocket, JsonElement payload, string chargePointId, string bindToken)
    {
        var request = OcppJson.Deserialize<StatusNotificationRequest>(payload) ?? new StatusNotificationRequest();
        await _handler.HandleStatusNotificationAsync(chargePointId, request);
        await SendMessageAsync(new StatusNotificationResponse(), webSocket, chargePointId);
    }
}

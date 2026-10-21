using System.Net.WebSockets;
using System.Text.Json;
using ChargingServer.Ocpp.Abstractions;
using ChargingServer.Ocpp.Json;
using ChargingServer.Ocpp.Models.Messages;
using Microsoft.Extensions.Logging;

namespace ChargingServer.Ocpp.Handlers;

public class BootNotificationHandler(string messageId, ILogger logger, IOcppHandler handler) : WithResponseHandler(messageId, true, logger)
{
    private readonly IOcppHandler _handler = handler;

    public override async Task ProcessAsync(WebSocket webSocket, JsonElement payload, string chargePointId, string bindToken)
    {
        var request = OcppJson.Deserialize<BootNotificationRequest>(payload) ?? new BootNotificationRequest();
        var response = await _handler.HandleBootNotificationAsync(bindToken, chargePointId, request);
        await SendMessageAsync(response, webSocket, chargePointId);
    }
}

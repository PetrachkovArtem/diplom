using System.Net.WebSockets;
using System.Text.Json;
using ChargingServer.Ocpp.Models.Messages;
using Microsoft.Extensions.Logging;

namespace ChargingServer.Ocpp.Handlers;

public class HeartbeatHandler(string messageId, ILogger logger) : WithResponseHandler(messageId, false, logger)
{
    public override Task ProcessAsync(WebSocket webSocket, JsonElement payload, string chargePointId, string bindToken)
    {
        return SendMessageAsync(new HeartbeatResponse { CurrentTime = DateTime.UtcNow }, webSocket, chargePointId);
    }
}

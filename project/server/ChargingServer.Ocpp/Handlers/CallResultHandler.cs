using System.Net.WebSockets;
using System.Text.Json;
using ChargingServer.Ocpp.Models;

namespace ChargingServer.Ocpp.Handlers;

public class CallResultHandler(string messageId, SendMessage requestedMessage) : BaseHandler(messageId)
{
    private readonly SendMessage _requestedMessage = requestedMessage;

    public override Task ProcessAsync(WebSocket webSocket, JsonElement payload, string chargePointId, string bindToken)
    {
        _requestedMessage.Tcs.TrySetResult(payload.ValueKind == JsonValueKind.Undefined
            ? "{}"
            : payload.GetRawText());
        return Task.CompletedTask;
    }
}

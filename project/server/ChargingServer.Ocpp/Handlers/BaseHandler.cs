using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using ChargingServer.Ocpp.Json;

namespace ChargingServer.Ocpp.Handlers;

public abstract class BaseHandler(string messageId)
{
    public string MessageId { get; } = messageId;

    public abstract Task ProcessAsync(WebSocket webSocket, JsonElement payload, string chargePointId, string bindToken);

    protected static Task SendErrorAsync(WebSocket webSocket, object error)
    {
        var response = JsonSerializer.Serialize(new object[] { 4, string.Empty, "ProtocolError", string.Empty, error }, OcppJson.Options);
        return webSocket.SendAsync(Encoding.UTF8.GetBytes(response), WebSocketMessageType.Text, true, CancellationToken.None);
    }
}

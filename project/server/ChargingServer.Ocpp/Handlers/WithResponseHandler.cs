using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using ChargingServer.Ocpp.Json;
using Microsoft.Extensions.Logging;

namespace ChargingServer.Ocpp.Handlers;

public abstract class WithResponseHandler : BaseHandler
{
    private readonly ILogger _logger;
    private readonly bool _logResponse;

    protected WithResponseHandler(string messageId, bool logResponse, ILogger logger) : base(messageId)
    {
        _logResponse = logResponse;
        _logger = logger;
    }

    protected Task SendMessageAsync<T>(T payload, WebSocket webSocket, string chargePointId)
    {
        var response = JsonSerializer.Serialize(new object?[] { 3, MessageId, payload }, OcppJson.Options);

        if (_logResponse)
        {
            _logger.LogInformation("CP <- {id}: {response}", chargePointId, response);
        }

        return webSocket.SendAsync(Encoding.UTF8.GetBytes(response), WebSocketMessageType.Text, true, CancellationToken.None);
    }
}

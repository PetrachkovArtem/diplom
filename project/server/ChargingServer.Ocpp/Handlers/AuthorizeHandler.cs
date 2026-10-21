using System.Net.WebSockets;
using System.Text.Json;
using ChargingServer.Ocpp.Models;
using ChargingServer.Ocpp.Models.Messages;
using Microsoft.Extensions.Logging;

namespace ChargingServer.Ocpp.Handlers;

public class AuthorizeHandler(string messageId, ILogger logger) : WithResponseHandler(messageId, true, logger)
{
    public override Task ProcessAsync(WebSocket webSocket, JsonElement payload, string chargePointId, string bindToken)
    {
        var response = new AuthorizeResponse
        {
            IdTokenInfo = new IdTokenInfoType { Status = AuthorizationStatus.Accepted }
        };
        return SendMessageAsync(response, webSocket, chargePointId);
    }
}

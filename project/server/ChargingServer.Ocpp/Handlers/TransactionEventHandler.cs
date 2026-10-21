using System.Net.WebSockets;
using System.Text.Json;
using ChargingServer.Ocpp.Abstractions;
using ChargingServer.Ocpp.Json;
using ChargingServer.Ocpp.Models;
using ChargingServer.Ocpp.Models.Messages;
using Microsoft.Extensions.Logging;

namespace ChargingServer.Ocpp.Handlers;

public class TransactionEventHandler : WithResponseHandler
{
    private readonly IOcppHandler _domain;

    public TransactionEventHandler(string messageId, ILogger logger, IOcppHandler domain)
        : base(messageId, true, logger)
    {
        _domain = domain;
    }

    public override async Task ProcessAsync(WebSocket webSocket, JsonElement payload, string chargePointId, string bindToken)
    {
        var request = OcppJson.Deserialize<TransactionEventRequest>(payload) ?? new TransactionEventRequest();
        await _domain.HandleTransactionEventAsync(chargePointId, request);

        var response = new TransactionEventResponse();
        if (request.IdToken != null)
        {
            response.IdTokenInfo = new IdTokenInfoType { Status = AuthorizationStatus.Accepted };
        }

        await SendMessageAsync(response, webSocket, chargePointId);
    }
}

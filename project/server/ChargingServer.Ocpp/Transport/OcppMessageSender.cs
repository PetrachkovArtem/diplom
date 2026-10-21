using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using ChargingServer.Ocpp.Json;
using ChargingServer.Ocpp.Models;
using ChargingServer.Ocpp.Models.Messages;
using Microsoft.Extensions.Logging;

namespace ChargingServer.Ocpp.Transport;

public sealed class OcppMessageSender(OcppConnectionStore store, ILoggerFactory loggerFactory)
{
    private readonly OcppConnectionStore _store = store;
    private readonly ILogger _logger = loggerFactory.CreateLogger(OcppLog.CategoryName);

    public async Task<(bool Accepted, string? TransactionId)> RequestStartTransactionAsync(string chargePointId, int evseId, int remoteStartId, string idToken, CancellationToken cancellationToken = default)
    {
        var response = await SendAsync<RequestStartTransactionResponse>(
            chargePointId,
            "RequestStartTransaction",
            new RequestStartTransactionRequest
            {
                EvseId = evseId,
                RemoteStartId = remoteStartId,
                IdToken = new IdTokenType
                {
                    IdToken = idToken,
                    Type = IdTokenEnumType.Central
                }
            },
            cancellationToken);

        return (response?.Status == RequestStartStopStatus.Accepted, response?.TransactionId);
    }

    public async Task<bool> RequestStopTransactionAsync(string chargePointId, string transactionId, CancellationToken cancellationToken = default)
    {
        var response = await SendAsync<RequestStopTransactionResponse>(
            chargePointId,
            "RequestStopTransaction",
            new RequestStopTransactionRequest { TransactionId = transactionId },
            cancellationToken);

        return response?.Status == RequestStartStopStatus.Accepted;
    }

    private async Task<TResponse?> SendAsync<TResponse>(string chargePointId, string action, object payload, CancellationToken cancellationToken)
    {
        if (!_store.TryGet(chargePointId, out var connection) || connection!.WebSocket.State != WebSocketState.Open)
        {
            throw new InvalidOperationException($"Нет соединения со станцией: {chargePointId}");
        }

        var pending = _store.TrackPending(chargePointId, action);
        var frame = JsonSerializer.Serialize(new object[] { 2, pending.Id, action, payload }, OcppJson.Options);
        _logger.LogInformation("CP <- {id}: {request}", chargePointId, frame);

        try
        {
            using var timeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
            timeout.CancelAfter(TimeSpan.FromSeconds(10));
            await connection.WebSocket.SendAsync(Encoding.UTF8.GetBytes(frame), WebSocketMessageType.Text, true, timeout.Token);
        }
        catch
        {
            _store.RemovePending(chargePointId, pending);
            throw;
        }

        var body = await pending.Tcs.Task.WaitAsync(cancellationToken);
        return OcppJson.Deserialize<TResponse>(body);
    }
}

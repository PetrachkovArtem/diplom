using System.Collections.Concurrent;
using System.Net.WebSockets;
using ChargingServer.Ocpp.Models;

namespace ChargingServer.Ocpp.Transport;

public class OcppConnectionStore
{
    private readonly ConcurrentDictionary<string, OcppWebSocketConnectionInfo> _connections = new();
    private readonly ConcurrentDictionary<string, List<SendMessage>> _pending = new();
    private readonly Lock _pendingLock = new();

    public bool IsConnected(string chargePointId)
    {
        return _connections.TryGetValue(chargePointId, out var info) && info.WebSocket.State == WebSocketState.Open;
    }

    public bool TryGet(string chargePointId, out OcppWebSocketConnectionInfo? info) =>
        _connections.TryGetValue(chargePointId, out info);

    public async Task SetConnectionAsync(string chargePointId, OcppWebSocketConnectionInfo info)
    {
        if (_connections.TryGetValue(chargePointId, out var existing) &&
            existing.WebSocket.State == WebSocketState.Open)
        {
            try
            {
                await existing.WebSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, string.Empty, CancellationToken.None);
            }
            catch
            {
                // ignore close errors on replace
            }

            AbortPending(chargePointId);
        }

        _connections[chargePointId] = info;
    }

    /// <summary>
    /// Removes the connection only if it is still the current one.
    /// Passing the closing WebSocket avoids wiping a newer reconnect.
    /// </summary>
    public void Remove(string chargePointId, WebSocket? closingSocket = null)
    {
        if (closingSocket != null &&
            _connections.TryGetValue(chargePointId, out var current) &&
            !ReferenceEquals(current.WebSocket, closingSocket))
        {
            return;
        }

        AbortPending(chargePointId);
        _connections.TryRemove(chargePointId, out _);
    }

    public SendMessage TrackPending(string chargePointId, string actionType)
    {
        var message = new SendMessage
        {
            Id = Guid.NewGuid().ToString("N"),
            ActionType = actionType
        };

        lock (_pendingLock)
        {
            var list = _pending.GetOrAdd(chargePointId, _ => []);
            list.Add(message);
        }

        return message;
    }

    public bool TryTakePending(string chargePointId, string messageId, out SendMessage? message)
    {
        lock (_pendingLock)
        {
            if (!_pending.TryGetValue(chargePointId, out var list))
            {
                message = null;
                return false;
            }

            message = list.FirstOrDefault(x => x.Id == messageId);
            if (message == null)
            {
                return false;
            }

            list.Remove(message);
            return true;
        }
    }

    public void RemovePending(string chargePointId, SendMessage message)
    {
        lock (_pendingLock)
        {
            if (_pending.TryGetValue(chargePointId, out var list))
            {
                list.Remove(message);
            }
        }
    }

    public void AbortPending(string chargePointId)
    {
        lock (_pendingLock)
        {
            if (!_pending.TryGetValue(chargePointId, out var list))
            {
                return;
            }

            foreach (var message in list.ToList())
            {
                message.Tcs.TrySetException(new InvalidOperationException("Потеряна связь со станцией"));
                list.Remove(message);
            }
        }
    }
}

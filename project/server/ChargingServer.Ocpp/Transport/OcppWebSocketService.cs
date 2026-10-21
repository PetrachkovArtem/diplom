using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using ChargingServer.Ocpp.Abstractions;
using ChargingServer.Ocpp.Handlers;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace ChargingServer.Ocpp.Transport;

public sealed class OcppWebSocketService(OcppConnectionStore store, IServiceScopeFactory scopeFactory, ILoggerFactory loggerFactory, IConfiguration configuration)
{
    private const int BufferSize = 4096;

    private readonly OcppConnectionStore _store = store;
    private readonly IServiceScopeFactory _scopeFactory = scopeFactory;
    private readonly ILogger _logger = loggerFactory.CreateLogger(OcppLog.CategoryName);
    private readonly IConfiguration _configuration = configuration;

    public async Task HandleConnectionAsync(string bindToken, string chargePointId, WebSocket webSocket)
    {
        await _store.SetConnectionAsync(chargePointId, new Models.OcppWebSocketConnectionInfo
        {
            WebSocket = webSocket,
            BindToken = bindToken,
            ChargePointId = chargePointId
        });

        {
            using var scope = _scopeFactory.CreateScope();
            var handler = scope.ServiceProvider.GetRequiredService<IOcppHandler>();
            await handler.HandleConnectionOpenedAsync(chargePointId);
        }

        try
        {
            WebSocketReceiveResult result;
            do
            {
                var buffer = new byte[BufferSize];
                result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                if (result.MessageType == WebSocketMessageType.Close)
                {
                    break;
                }

                var count = result.Count;
                if (!result.EndOfMessage)
                {
                    using var ms = new MemoryStream();
                    ms.Write(buffer, 0, count);
                    do
                    {
                        buffer = new byte[BufferSize];
                        result = await webSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                        ms.Write(buffer, 0, result.Count);
                    } while (!result.EndOfMessage);

                    await HandleMessageAsync(bindToken, chargePointId, Encoding.UTF8.GetString(ms.ToArray()));
                }
                else
                {
                    await HandleMessageAsync(bindToken, chargePointId, Encoding.UTF8.GetString(buffer, 0, count));
                }
            } while (!result.CloseStatus.HasValue);
        }
        catch (Exception ex)
        {
            if (_configuration.GetValue("LogWSError", false))
            {
                _logger.LogError("WS Error: {ex}", ex.ToString());
            }
        }
        finally
        {
            _store.Remove(chargePointId, webSocket);
            using var scope = _scopeFactory.CreateScope();
            var handler = scope.ServiceProvider.GetRequiredService<IOcppHandler>();
            await handler.HandleConnectionClosedAsync(chargePointId, webSocket);
        }
    }

    private async Task HandleMessageAsync(string bindToken, string chargePointId, string message)
    {
        message = message.Trim('\0');
        if (string.IsNullOrWhiteSpace(message))
        {
            return;
        }

        _logger.LogInformation("CP -> {cp}: {message}", chargePointId, message);

        using var document = JsonDocument.Parse(message);
        var array = document.RootElement;
        if (array.ValueKind != JsonValueKind.Array || array.GetArrayLength() < 2)
        {
            return;
        }

        var type = array[0].GetInt32();
        var messageId = array[1].GetString() ?? string.Empty;

        using var scope = _scopeFactory.CreateScope();
        var domain = scope.ServiceProvider.GetRequiredService<IOcppHandler>();
        var factory = scope.ServiceProvider.GetRequiredService<OcppMessageHandlerFactory>();

        if (type == 4)
        {
            if (_store.TryTakePending(chargePointId, messageId, out var failed) && failed != null)
            {
                var error = array.GetArrayLength() > 4 ? array[4].GetRawText() : message;
                failed.Tcs.TrySetException(new InvalidOperationException($"CALLERROR: {error}"));
            }

            await domain.LogMessageAsync(chargePointId, "In", "CALLERROR", message);
            return;
        }

        string actionName;
        JsonElement payload = default;

        if (_store.TryTakePending(chargePointId, messageId, out Models.SendMessage? pending) && pending != null)
        {
            actionName = pending.ActionType;
            if (array.GetArrayLength() > 2)
            {
                payload = array[2];
            }
        }
        else
        {
            if (array.GetArrayLength() < 3)
            {
                return;
            }

            actionName = array[2].GetString() ?? string.Empty;
            if (array.GetArrayLength() > 3)
            {
                payload = array[3];
            }
        }

        await domain.LogMessageAsync(chargePointId, "In", actionName, message);

        if (!_store.TryGet(chargePointId, out var connection) || connection == null)
        {
            return;
        }

        var handler = factory.Create(actionName, messageId, pending);
        if (handler != null)
        {
            await handler.ProcessAsync(connection.WebSocket, payload, chargePointId, bindToken);
        }
    }
}

using ChargingServer.Ocpp.Abstractions;
using ChargingServer.Ocpp.Models;
using Microsoft.Extensions.Logging;

namespace ChargingServer.Ocpp.Handlers;

public class OcppMessageHandlerFactory(ILoggerFactory loggerFactory, IOcppHandler handler)
{
    private readonly ILoggerFactory _loggerFactory = loggerFactory;
    private readonly IOcppHandler _handler = handler;

    public BaseHandler? Create(string actionName, string messageId, SendMessage? pending)
    {
        if (pending != null)
        {
            return new CallResultHandler(messageId, pending);
        }

        var logger = _loggerFactory.CreateLogger(OcppLog.CategoryName);

        return actionName switch
        {
            "BootNotification" => new BootNotificationHandler(messageId, logger, _handler),
            "Heartbeat" => new HeartbeatHandler(messageId, logger),
            "Authorize" => new AuthorizeHandler(messageId, logger),
            "StatusNotification" => new StatusNotificationHandler(messageId, logger, _handler),
            "TransactionEvent" => new TransactionEventHandler(messageId, logger, _handler),
            _ => null
        };
    }
}

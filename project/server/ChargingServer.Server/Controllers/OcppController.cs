using ChargingServer.Ocpp;
using ChargingServer.Ocpp.Transport;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargingServer.Server.Controllers;

[ApiController]
public sealed class OcppController(OcppWebSocketService ocppWebSocketService, ILoggerFactory loggerFactory) : Controller
{
    private readonly ILogger _logger = loggerFactory.CreateLogger(OcppLog.CategoryName);

    [HttpGet("/ocpp/{bindToken}/{chargePointId}")]
    [AllowAnonymous]
    public async Task Connect(string bindToken, string chargePointId)
    {
        if (!HttpContext.WebSockets.IsWebSocketRequest)
        {
            HttpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
            await HttpContext.Response.WriteAsync("Expected WebSocket connection with OCPP 2.0.1.");
            return;
        }

        string? acceptProtocol = null;
        if (HttpContext.Request.Headers.TryGetValue("Sec-WebSocket-Protocol", out var protocolValue))
        {
            _logger.LogInformation(
                "CP -> {id}: Init connect with Sec-WebSocket-Protocol={protocolValue}",
                chargePointId,
                protocolValue.ToString());

            var supported = protocolValue.ToString().Split(',').Select(x => x.Trim()).ToArray();
            if (!supported.Contains("ocpp2.0.1", StringComparer.OrdinalIgnoreCase))
            {
                _logger.LogWarning("Rejected OCPP connection without ocpp2.0.1 subprotocol: {Protocols}", protocolValue.ToString());
                HttpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
                await HttpContext.Response.WriteAsync("Only ocpp2.0.1 is supported.");
                return;
            }

            acceptProtocol = "ocpp2.0.1";
        }
        else
        {
            _logger.LogInformation(
                "CP -> {id}: Init connect without Sec-WebSocket-Protocol, other headers.\n{headers}",
                chargePointId,
                string.Join("\n", HttpContext.Request.Headers.Select(x => $"{x.Key}={x.Value}")));
            HttpContext.Response.StatusCode = StatusCodes.Status400BadRequest;
            await HttpContext.Response.WriteAsync("Only ocpp2.0.1 is supported.");
            return;
        }

        using var socket = await HttpContext.WebSockets.AcceptWebSocketAsync(acceptProtocol);
        await ocppWebSocketService.HandleConnectionAsync(bindToken.Trim().ToUpperInvariant(), chargePointId, socket);
    }
}

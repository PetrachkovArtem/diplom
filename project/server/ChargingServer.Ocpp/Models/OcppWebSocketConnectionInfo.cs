using System.Net.WebSockets;

namespace ChargingServer.Ocpp.Models;

public class OcppWebSocketConnectionInfo
{
    public required WebSocket WebSocket { get; init; }
    public required string BindToken { get; init; }
    public required string ChargePointId { get; init; }
}

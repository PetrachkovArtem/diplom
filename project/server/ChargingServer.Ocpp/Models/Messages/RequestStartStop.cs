using ChargingServer.Ocpp.Models;

namespace ChargingServer.Ocpp.Models.Messages;

public class RequestStartTransactionRequest
{
    public int? EvseId { get; set; }
    public int RemoteStartId { get; set; }
    public IdTokenType IdToken { get; set; } = new();
    public IdTokenType? GroupIdToken { get; set; }
}

public class RequestStartTransactionResponse
{
    public RequestStartStopStatus Status { get; set; }
    public string? TransactionId { get; set; }
    public StatusInfo? StatusInfo { get; set; }
}

public class RequestStopTransactionRequest
{
    public string TransactionId { get; set; } = string.Empty;
}

public class RequestStopTransactionResponse
{
    public RequestStartStopStatus Status { get; set; }
    public StatusInfo? StatusInfo { get; set; }
}

public enum RequestStartStopStatus
{
    Accepted,
    Rejected
}

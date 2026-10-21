namespace ChargingServer.Ocpp.Models;

public class IdTokenType
{
    public string IdToken { get; set; } = string.Empty;
    public IdTokenEnumType Type { get; set; }
}

public enum IdTokenEnumType
{
    Central,
    eMAID,
    ISO14443,
    ISO15693,
    KeyCode,
    Local,
    MacAddress,
    NoAuthorization
}

public class IdTokenInfoType
{
    public AuthorizationStatus Status { get; set; }
    public DateTime? CacheExpiryDateTime { get; set; }
    public IdTokenType? GroupIdToken { get; set; }
    public StatusInfo? StatusInfo { get; set; }
}

public enum AuthorizationStatus
{
    Accepted,
    Blocked,
    ConcurrentTx,
    Expired,
    Invalid,
    NoCredit,
    NotAllowedTypeEV,
    NotAtThisLocation,
    NotAtThisTime,
    Unknown
}

public class StatusInfo
{
    public string? ReasonCode { get; set; }
    public string? AdditionalInfo { get; set; }
}

public class EvseType
{
    public int Id { get; set; }
    public int? ConnectorId { get; set; }
}

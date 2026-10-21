using ChargingServer.Ocpp.Models;

namespace ChargingServer.Ocpp.Models.Messages;

public class TransactionEventRequest
{
    public TransactionEventType EventType { get; set; }
    public DateTime Timestamp { get; set; }
    public TriggerReason TriggerReason { get; set; }
    public int SeqNo { get; set; }
    public bool? Offline { get; set; }
    public TransactionType? TransactionInfo { get; set; }
    public IdTokenType? IdToken { get; set; }
    public EvseType? Evse { get; set; }
    public List<MeterValueType>? MeterValue { get; set; }
}

public class TransactionType
{
    public string TransactionId { get; set; } = string.Empty;
    public ChargingState? ChargingState { get; set; }
    public int? TimeSpentCharging { get; set; }
    public StopReason? StoppedReason { get; set; }
    public int? RemoteStartId { get; set; }
}

public class MeterValueType
{
    public DateTime Timestamp { get; set; }
    public List<SampledValueType>? SampledValue { get; set; }
}

public class SampledValueType
{
    public decimal Value { get; set; }
    public string? Context { get; set; }
    public string? Measurand { get; set; }
    public string? Phase { get; set; }
    public string? Location { get; set; }
    public UnitOfMeasureType? UnitOfMeasure { get; set; }
}

public class UnitOfMeasureType
{
    public string? Unit { get; set; }
    public int? Multiplier { get; set; }
}

public enum TransactionEventType
{
    Started,
    Updated,
    Ended
}

public enum TriggerReason
{
    Authorized,
    CablePluggedIn,
    ChargingRateChanged,
    ChargingStateChanged,
    Deauthorized,
    EnergyLimitReached,
    EVCommunicationLost,
    EVConnectTimeout,
    MeterValueClock,
    MeterValuePeriodic,
    TimeLimitReached,
    Trigger,
    UnlockCommand,
    StopAuthorized,
    EVDeparted,
    EVDetected,
    RemoteStop,
    RemoteStart,
    AbnormalCondition,
    SignedDataReceived,
    ResetCommand
}

public enum ChargingState
{
    Charging,
    EVConnected,
    SuspendedEV,
    SuspendedEVSE,
    Idle
}

public enum StopReason
{
    DeAuthorized,
    EmergencyStop,
    EnergyLimitReached,
    EVDisconnected,
    GroundFault,
    ImmediateReset,
    Local,
    LocalOutOfCredit,
    MasterPass,
    Other,
    OvercurrentFault,
    PowerLoss,
    PowerQuality,
    Reboot,
    Remote,
    SOCLimitReached,
    StoppedByEV,
    TimeLimitReached,
    Timeout
}

public class TransactionEventResponse
{
    public decimal? TotalCost { get; set; }
    public int? ChargingPriority { get; set; }
    public IdTokenInfoType? IdTokenInfo { get; set; }
}

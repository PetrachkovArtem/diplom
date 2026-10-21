using ChargingServer.Ocpp.Models;

namespace ChargingServer.Ocpp.Models.Messages;

public class BootNotificationRequest
{
    public BootReason Reason { get; set; }
    public ChargingStation? ChargingStation { get; set; }
}

public class ChargingStation
{
    public string? SerialNumber { get; set; }
    public string? Model { get; set; }
    public string? VendorName { get; set; }
    public string? FirmwareVersion { get; set; }
}

public enum BootReason
{
    ApplicationReset,
    FirmwareUpdate,
    LocalReset,
    PowerUp,
    RemoteReset,
    ScheduledReset,
    Triggered,
    Unknown,
    Watchdog
}

public class BootNotificationResponse
{
    public RegistrationStatus Status { get; set; }
    public DateTime CurrentTime { get; set; }
    public int Interval { get; set; }
    public StatusInfo? StatusInfo { get; set; }
}

public enum RegistrationStatus
{
    Accepted,
    Pending,
    Rejected
}

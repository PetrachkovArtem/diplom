namespace ChargingServer.Ocpp.Models.Messages;

public class StatusNotificationRequest
{
    public DateTime Timestamp { get; set; }
    public ConnectorStatus ConnectorStatus { get; set; }
    public int EvseId { get; set; }
    public int ConnectorId { get; set; }
}

public enum ConnectorStatus
{
    Available,
    Occupied,
    Reserved,
    Unavailable,
    Faulted
}

public class StatusNotificationResponse;

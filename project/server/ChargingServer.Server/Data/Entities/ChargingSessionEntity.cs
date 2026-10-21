namespace ChargingServer.Server.Data.Entities;

public class ChargingSessionEntity
{
    public Guid Id { get; set; }
    public Guid AccountId { get; set; }
    public AccountEntity Account { get; set; } = null!;
    public Guid StationId { get; set; }
    public StationEntity Station { get; set; } = null!;
    public Guid ConnectorId { get; set; }
    public ConnectorEntity Connector { get; set; } = null!;
    public string? OcppTransactionId { get; set; }
    public int RemoteStartId { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public decimal? MeterStart { get; set; }
    public decimal? MeterLast { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

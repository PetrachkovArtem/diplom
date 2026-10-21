namespace ChargingServer.Server.Data.Entities;

public class StationEntity
{
    public Guid Id { get; set; }
    public Guid AccountId { get; set; }
    public AccountEntity Account { get; set; } = null!;
    public string OcppChargePointId { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public bool IsOnline { get; set; }
    public DateTime? LastBootAt { get; set; }
    public string? VendorName { get; set; }
    public string? Model { get; set; }

    public ICollection<ConnectorEntity> Connectors { get; set; } = [];
    public ICollection<ChargingSessionEntity> Sessions { get; set; } = [];
}

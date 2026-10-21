namespace ChargingServer.Server.Data.Entities;

public class ConnectorEntity
{
    public Guid Id { get; set; }
    public Guid StationId { get; set; }
    public StationEntity Station { get; set; } = null!;
    public int EvseId { get; set; }
    public int ConnectorNumber { get; set; }
    public string Status { get; set; } = "Unavailable";
    public string? ConnectorType { get; set; }

    public ICollection<ChargingSessionEntity> Sessions { get; set; } = [];
}

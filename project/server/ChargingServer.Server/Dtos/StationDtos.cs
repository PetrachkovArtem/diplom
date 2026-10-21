namespace ChargingServer.Server.Dtos;

public class StationDto
{
    public Guid Id { get; set; }
    public string OcppChargePointId { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public bool IsOnline { get; set; }
    public int ConnectorCount { get; set; }
    public bool HasCurrentSession { get; set; }
    public List<ConnectorDto> Connectors { get; set; } = [];
}

public class ConnectorDto
{
    public Guid Id { get; set; }
    public int EvseId { get; set; }
    public int ConnectorNumber { get; set; }
    public string Status { get; set; } = string.Empty;
}

public class RenameStationRequest
{
    public string DisplayName { get; set; } = string.Empty;
}

public class BindUrlResponse
{
    public string BindToken { get; set; } = string.Empty;
    public string UrlTemplate { get; set; } = string.Empty;
}

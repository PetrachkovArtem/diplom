namespace ChargingServer.Server.Dtos;

public class StartSessionRequest
{
    public Guid StationId { get; set; }
    public Guid ConnectorId { get; set; }
}

public class StopSessionRequest
{
    public Guid StationId { get; set; }
}

public class SessionDto
{
    public Guid Id { get; set; }
    public Guid StationId { get; set; }
    public string StationName { get; set; } = string.Empty;
    public Guid ConnectorId { get; set; }
    public int ConnectorNumber { get; set; }
    public string? OcppTransactionId { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public decimal? MeterStart { get; set; }
    public decimal? MeterLast { get; set; }
    public decimal? EnergyKwh { get; set; }
    public decimal? BatterySoc { get; set; }
    public decimal? PricePerKwh { get; set; }
    public decimal? Cost { get; set; }
    public bool IsCurrent { get; set; }
}

public class PagedResult<T>
{
    public List<T> Items { get; set; } = [];
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int Total { get; set; }
}

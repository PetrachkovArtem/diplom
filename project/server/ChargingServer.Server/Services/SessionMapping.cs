using ChargingServer.Server.Data.Entities;
using ChargingServer.Server.Dtos;

namespace ChargingServer.Server.Services;

internal static class SessionMapping
{
    public static SessionDto ToDto(ChargingSessionEntity session)
    {
        decimal? energy = null;
        if (session.MeterStart.HasValue && session.MeterLast.HasValue)
        {
            energy = session.MeterLast.Value - session.MeterStart.Value;
        }

        var price = session.PricePerKwh ?? (session.EndedAt == null ? session.Account?.PricePerKwh : null);
        
        decimal? cost = null;

        if (energy.HasValue && price.HasValue)
        {
            cost = energy.Value * price.Value;
        }

        return new SessionDto
        {
            Id = session.Id,
            StationId = session.StationId,
            StationName = session.Station.DisplayName,
            ConnectorId = session.ConnectorId,
            ConnectorNumber = session.Connector.ConnectorNumber,
            OcppTransactionId = session.OcppTransactionId,
            StartedAt = session.StartedAt,
            EndedAt = session.EndedAt,
            MeterStart = session.MeterStart,
            MeterLast = session.MeterLast,
            EnergyKwh = energy,
            BatterySoc = session.BatterySoc,
            PricePerKwh = price,
            Cost = cost,
            IsCurrent = session.EndedAt == null
        };
    }
}

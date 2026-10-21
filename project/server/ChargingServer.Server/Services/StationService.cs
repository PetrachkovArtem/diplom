using ChargingServer.Ocpp.Transport;
using ChargingServer.Server.Data;
using ChargingServer.Server.Data.Entities;
using ChargingServer.Server.Dtos;
using Microsoft.EntityFrameworkCore;

namespace ChargingServer.Server.Services;

public class StationService(AppDbContext db, IHttpContextAccessor httpContextAccessor, OcppConnectionStore connectionStore)
{
    public async Task<List<StationDto>> ListAsync(Guid accountId)
    {
        var stations = await db.Stations
            .AsNoTracking()
            .Include(x => x.Connectors)
            .Where(x => x.AccountId == accountId)
            .OrderBy(x => x.DisplayName)
            .ToListAsync();

        var currentStationIds = await db.Sessions
            .AsNoTracking()
            .Where(x => x.AccountId == accountId && x.EndedAt == null)
            .Select(x => x.StationId)
            .ToListAsync();

        return [.. stations.Select(s => Map(s, currentStationIds.Contains(s.Id)))];
    }

    public async Task<StationDto> RenameAsync(Guid accountId, Guid stationId, string displayName)
    {
        if (string.IsNullOrWhiteSpace(displayName))
        {
            throw new InvalidOperationException("Имя станции не может быть пустым.");
        }

        var station = await db.Stations.Include(x => x.Connectors)
            .FirstOrDefaultAsync(x => x.Id == stationId && x.AccountId == accountId) ?? throw new InvalidOperationException("Станция не найдена.");

        station.DisplayName = displayName.Trim();
        await db.SaveChangesAsync();

        var hasCurrent = await db.Sessions.AnyAsync(x => x.StationId == station.Id && x.EndedAt == null);
        return Map(station, hasCurrent);
    }

    public async Task<StationDto?> GetAsync(Guid accountId, Guid stationId)
    {
        var station = await db.Stations
            .AsNoTracking()
            .Include(x => x.Connectors)
            .FirstOrDefaultAsync(x => x.Id == stationId && x.AccountId == accountId);

        if (station == null)
        {
            return null;
        }

        var hasCurrent = await db.Sessions.AnyAsync(x => x.StationId == station.Id && x.EndedAt == null);
        return Map(station, hasCurrent);
    }

    public async Task DeleteAsync(Guid accountId, Guid stationId)
    {
        var station = await db.Stations
            .FirstOrDefaultAsync(x => x.Id == stationId && x.AccountId == accountId) ?? throw new InvalidOperationException("Станция не найдена.");

        if (await db.Sessions.AnyAsync(x => x.StationId == stationId && x.EndedAt == null))
        {
            throw new InvalidOperationException("Нельзя удалить станцию с активной сессией.");
        }

        db.Stations.Remove(station);
        await db.SaveChangesAsync();
    }

    public async Task<BindUrlResponse> GetBindUrlAsync(Guid accountId)
    {
        var account = await db.Accounts.AsNoTracking().FirstAsync(x => x.Id == accountId);
        var request = httpContextAccessor.HttpContext?.Request;
        var baseUrl = request == null ? "wss://localhost" : $"{(request.IsHttps ? "wss" : "ws")}://{request.Host}";

        return new BindUrlResponse
        {
            BindToken = account.BindToken,
            UrlTemplate = $"{baseUrl}/ocpp/{account.BindToken}",
        };
    }

    private StationDto Map(StationEntity station, bool hasCurrent) => new()
    {
        Id = station.Id,
        OcppChargePointId = station.OcppChargePointId,
        DisplayName = station.DisplayName,
        IsOnline = connectionStore.IsConnected(station.OcppChargePointId),
        ConnectorCount = station.Connectors.Count,
        HasCurrentSession = hasCurrent,
        Connectors = [.. station.Connectors.OrderBy(c => c.EvseId).ThenBy(c => c.ConnectorNumber).Select(c => new ConnectorDto
        {
            Id = c.Id,
            EvseId = c.EvseId,
            ConnectorNumber = c.ConnectorNumber,
            Status = c.Status
        })]
    };
}

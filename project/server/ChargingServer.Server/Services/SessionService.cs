using ChargingServer.Ocpp.Transport;
using ChargingServer.Server.Data;
using ChargingServer.Server.Data.Entities;
using ChargingServer.Server.Dtos;
using ChargingServer.Server.Hubs;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace ChargingServer.Server.Services;

public class SessionService(AppDbContext db, OcppMessageSender ocppSender, OcppConnectionStore connectionStore, IHubContext<SessionHub> hub)
{
    public async Task<SessionDto> StartAsync(Guid accountId, StartSessionRequest request)
    {
        var station = await db.Stations
            .Include(x => x.Connectors)
            .FirstOrDefaultAsync(x => x.Id == request.StationId && x.AccountId == accountId)
            ?? throw new InvalidOperationException("Станция не найдена.");

        if (await db.Sessions.AnyAsync(x => x.StationId == station.Id && x.EndedAt == null))
        {
            throw new InvalidOperationException("На этой станции уже есть активная сессия.");
        }

        if (!station.IsOnline || !connectionStore.IsConnected(station.OcppChargePointId))
        {
            throw new InvalidOperationException("Станция недоступна (нет соединения).");
        }

        var connector = station.Connectors.FirstOrDefault(x => x.Id == request.ConnectorId)
            ?? throw new InvalidOperationException("Коннектор не найден.");

        var remoteStartId = Random.Shared.Next(1, int.MaxValue);
        var (accepted, transactionId) = await ocppSender.RequestStartTransactionAsync(
            station.OcppChargePointId,
            connector.EvseId,
            remoteStartId,
            accountId.ToString("N"));

        if (!accepted)
        {
            throw new InvalidOperationException("Станция отклонила команду запуска зарядки.");
        }

        var session = new ChargingSessionEntity
        {
            Id = Guid.NewGuid(),
            AccountId = accountId,
            StationId = station.Id,
            ConnectorId = connector.Id,
            OcppTransactionId = transactionId,
            RemoteStartId = remoteStartId,
            CreatedAt = DateTime.UtcNow
        };

        db.Sessions.Add(session);
        await db.SaveChangesAsync();

        var dto = await GetDtoAsync(session.Id);
        await hub.Clients.Group(SessionHub.UserGroup(accountId)).SendAsync("SessionUpdated", dto);
        return dto;
    }

    public async Task<SessionDto> StopAsync(Guid accountId, Guid stationId)
    {
        var session = await db.Sessions
            .Include(x => x.Station)
            .FirstOrDefaultAsync(x =>
                x.AccountId == accountId &&
                x.StationId == stationId &&
                x.EndedAt == null)
            ?? throw new InvalidOperationException("Нет активной сессии на этой станции.");

        if (string.IsNullOrWhiteSpace(session.OcppTransactionId))
        {
            session.StartedAt = session.EndedAt = DateTime.UtcNow;
            session.MeterStart = session.MeterLast = 0;

            await db.SaveChangesAsync();

            var dto = await GetDtoAsync(session.Id);
            await hub.Clients.Group(SessionHub.UserGroup(accountId)).SendAsync("SessionUpdated", dto);
            return dto;
        }

        if (!connectionStore.IsConnected(session.Station.OcppChargePointId))
        {
            throw new InvalidOperationException("Станция недоступна (нет соединения).");
        }

        var accepted = await ocppSender.RequestStopTransactionAsync(
            session.Station.OcppChargePointId,
            session.OcppTransactionId);

        if (!accepted)
        {
            throw new InvalidOperationException("Станция отклонила команду остановки зарядки.");
        }

        return await GetDtoAsync(session.Id);
    }

    public async Task<SessionDto?> GetCurrentAsync(Guid accountId, Guid stationId)
    {
        var ownsStation = await db.Stations.AnyAsync(x => x.Id == stationId && x.AccountId == accountId);
        if (!ownsStation)
        {
            throw new InvalidOperationException("Станция не найдена.");
        }

        var session = await db.Sessions.AsNoTracking()
            .Where(x => x.AccountId == accountId && x.StationId == stationId && x.EndedAt == null)
            .Select(x => x.Id)
            .FirstOrDefaultAsync();

        return session == Guid.Empty ? null : await GetDtoAsync(session);
    }

    public async Task<PagedResult<SessionDto>> GetHistoryAsync(Guid accountId, int page, int pageSize)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 100);

        var query = db.Sessions.AsNoTracking()
            .Where(x => x.AccountId == accountId && x.EndedAt != null)
            .OrderByDescending(x => x.EndedAt);

        var total = await query.CountAsync();
        var ids = await query.Skip((page - 1) * pageSize).Take(pageSize).Select(x => x.Id).ToListAsync();
        var items = new List<SessionDto>();
        foreach (var id in ids)
        {
            items.Add(await GetDtoAsync(id));
        }

        return new PagedResult<SessionDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            Total = total
        };
    }

    public async Task<SessionDto> GetByIdAsync(Guid accountId, Guid sessionId)
    {
        var exists = await db.Sessions.AnyAsync(x => x.Id == sessionId && x.AccountId == accountId);
        if (!exists)
        {
            throw new InvalidOperationException("Сессия не найдена.");
        }

        return await GetDtoAsync(sessionId);
    }

    private async Task<SessionDto> GetDtoAsync(Guid sessionId)
    {
        var session = await db.Sessions.AsNoTracking()
            .Include(x => x.Station)
            .Include(x => x.Connector)
            .Include(x => x.Account)
            .FirstAsync(x => x.Id == sessionId);

        return SessionMapping.ToDto(session);
    }
}

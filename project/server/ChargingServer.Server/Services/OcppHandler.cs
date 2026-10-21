using System.Net.WebSockets;
using ChargingServer.Ocpp.Abstractions;
using ChargingServer.Ocpp.Models.Messages;
using ChargingServer.Ocpp.Transport;
using ChargingServer.Server.Data;
using ChargingServer.Server.Data.Entities;
using ChargingServer.Server.Dtos;
using ChargingServer.Server.Hubs;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace ChargingServer.Server.Services;

public class OcppHandler(AppDbContext db, OcppConnectionStore connectionStore, IHubContext<SessionHub> hub, ILogger<OcppHandler> logger) : IOcppHandler
{
    public async Task<BootNotificationResponse> HandleBootNotificationAsync(string bindToken, string chargePointId, BootNotificationRequest request, CancellationToken cancellationToken = default)
    {
        var normalizedToken = bindToken.Trim().ToUpperInvariant();
        var account = await db.Accounts.FirstOrDefaultAsync(x => x.BindToken == normalizedToken, cancellationToken);
        if (account == null || account.IsBlocked || account.Role != AccountRole.User)
        {
            return new BootNotificationResponse
            {
                Status = RegistrationStatus.Rejected,
                CurrentTime = DateTime.UtcNow,
                Interval = 40
            };
        }

        var station = await db.Stations.FirstOrDefaultAsync(x => x.OcppChargePointId == chargePointId, cancellationToken);
        if (station != null && station.AccountId != account.Id)
        {
            return new BootNotificationResponse
            {
                Status = RegistrationStatus.Rejected,
                CurrentTime = DateTime.UtcNow,
            };
        }

        if (station == null)
        {
            station = new StationEntity
            {
                Id = Guid.NewGuid(),
                AccountId = account.Id,
                OcppChargePointId = chargePointId,
                DisplayName = chargePointId,
                VendorName = request.ChargingStation?.VendorName,
                Model = request.ChargingStation?.Model
            };
            db.Stations.Add(station);
        }

        station.IsOnline = true;
        station.LastBootAt = DateTime.UtcNow;
        station.VendorName = request.ChargingStation?.VendorName ?? station.VendorName;
        station.Model = request.ChargingStation?.Model ?? station.Model;
        await db.SaveChangesAsync(cancellationToken);

        await NotifyStationsChanged(account.Id);

        return new BootNotificationResponse
        {
            Status = RegistrationStatus.Accepted,
            CurrentTime = DateTime.UtcNow,
            Interval = 60
        };
    }

    public async Task HandleStatusNotificationAsync(string chargePointId, StatusNotificationRequest request, CancellationToken cancellationToken = default)
    {
        var station = await db.Stations
            .Include(x => x.Connectors)
            .FirstOrDefaultAsync(x => x.OcppChargePointId == chargePointId, cancellationToken);

        if (station == null)
        {
            logger.LogWarning("StatusNotification for unknown station {ChargePointId}", chargePointId);
            return;
        }

        // EvseId=0 и ConnectorId=0 — статус станции, для нас не используется
        if (request.EvseId == 0 && request.ConnectorId == 0)
        {
            return;
        }

        var connector = station.Connectors.FirstOrDefault(x =>
            x.EvseId == request.EvseId && x.ConnectorNumber == request.ConnectorId);

        if (connector == null)
        {
            connector = new ConnectorEntity
            {
                Id = Guid.NewGuid(),
                StationId = station.Id,
                EvseId = request.EvseId,
                ConnectorNumber = request.ConnectorId
            };
            db.Connectors.Add(connector);
        }

        connector.Status = request.ConnectorStatus.ToString();
        station.IsOnline = connectionStore.IsConnected(chargePointId);
        await db.SaveChangesAsync(cancellationToken);
        await NotifyStationsChanged(station.AccountId);
    }

    public async Task HandleTransactionEventAsync(string chargePointId, TransactionEventRequest request, CancellationToken cancellationToken = default)
    {
        var station = await db.Stations.FirstOrDefaultAsync(x => x.OcppChargePointId == chargePointId, cancellationToken);
        if (station == null)
        {
            return;
        }

        var ocppTxId = request.TransactionInfo?.TransactionId;
        var meter = ExtractEnergyKwh(request);

        ChargingSessionEntity? session = null;
        if (!string.IsNullOrWhiteSpace(ocppTxId))
        {
            session = await db.Sessions.FirstOrDefaultAsync(
                x => x.StationId == station.Id && x.OcppTransactionId == ocppTxId,
                cancellationToken);
        }

        session ??= await db.Sessions
            .Where(x => x.StationId == station.Id && x.EndedAt == null)
            .OrderByDescending(x => x.CreatedAt)
            .FirstOrDefaultAsync(cancellationToken);

        if (session == null)
        {
            if (request.EventType != TransactionEventType.Started)
            {
                return;
            }

            var connectorNumber = request.Evse?.ConnectorId ?? 1;
            var evseId = request.Evse?.Id ?? 1;
            var connector = await db.Connectors.FirstOrDefaultAsync(
                x => x.StationId == station.Id && x.EvseId == evseId && x.ConnectorNumber == connectorNumber,
                cancellationToken);

            if (connector == null)
            {
                connector = new ConnectorEntity
                {
                    Id = Guid.NewGuid(),
                    StationId = station.Id,
                    EvseId = evseId,
                    ConnectorNumber = connectorNumber,
                    Status = "Occupied"
                };
                db.Connectors.Add(connector);
            }

            session = new ChargingSessionEntity
            {
                Id = Guid.NewGuid(),
                AccountId = station.AccountId,
                StationId = station.Id,
                ConnectorId = connector.Id,
                OcppTransactionId = ocppTxId,
                RemoteStartId = request.TransactionInfo?.RemoteStartId ?? 0,
                CreatedAt = DateTime.UtcNow
            };
            db.Sessions.Add(session);
        }

        if (!string.IsNullOrWhiteSpace(ocppTxId))
        {
            session.OcppTransactionId = ocppTxId;
        }

        switch (request.EventType)
        {
            case TransactionEventType.Started:
                session.StartedAt ??= request.Timestamp.ToUniversalTime();
                if (meter.HasValue)
                {
                    session.MeterStart ??= meter;
                    session.MeterLast = meter;
                }
                break;
            case TransactionEventType.Updated:
                if (meter.HasValue)
                {
                    session.MeterLast = meter;
                }
                break;
            case TransactionEventType.Ended:
                session.EndedAt = request.Timestamp.ToUniversalTime();
                if (meter.HasValue)
                {
                    session.MeterLast = meter;
                    session.MeterStart ??= meter;
                }
                break;
        }

        await db.SaveChangesAsync(cancellationToken);

        var dto = await MapSessionDto(session.Id, cancellationToken);
        await hub.Clients.Group(SessionHub.UserGroup(session.AccountId))
            .SendAsync("SessionUpdated", dto, cancellationToken);
    }

    public async Task HandleConnectionOpenedAsync(string chargePointId, CancellationToken cancellationToken = default)
    {
        var station = await db.Stations.FirstOrDefaultAsync(x => x.OcppChargePointId == chargePointId, cancellationToken);
        if (station == null)
        {
            return;
        }

        if (!station.IsOnline)
        {
            station.IsOnline = true;
            await db.SaveChangesAsync(cancellationToken);
        }

        await NotifyStationsChanged(station.AccountId);
    }

    public async Task HandleConnectionClosedAsync(string chargePointId, WebSocket? closingSocket = null, CancellationToken cancellationToken = default)
    {
        // Reconnect race: a newer socket may already be registered.
        if (connectionStore.IsConnected(chargePointId))
        {
            return;
        }

        if (closingSocket != null &&
            connectionStore.TryGet(chargePointId, out var current) &&
            current != null &&
            !ReferenceEquals(current.WebSocket, closingSocket))
        {
            return;
        }

        var station = await db.Stations.FirstOrDefaultAsync(x => x.OcppChargePointId == chargePointId, cancellationToken);
        if (station == null)
        {
            return;
        }

        station.IsOnline = false;
        await db.SaveChangesAsync(cancellationToken);
        await NotifyStationsChanged(station.AccountId);
    }

    public async Task LogMessageAsync(string? chargePointId, string direction, string action, string payload, CancellationToken cancellationToken = default)
    {

    }

    private async Task NotifyStationsChanged(Guid accountId)
    {
        await hub.Clients.Group(SessionHub.UserGroup(accountId)).SendAsync("StationsChanged");
    }

    private static decimal? ExtractEnergyKwh(TransactionEventRequest request)
    {
        var samples = request.MeterValue?
            .SelectMany(x => x.SampledValue ?? [])
            .Where(x => string.IsNullOrEmpty(x.Measurand) ||
                        x.Measurand.Equals("Energy.Active.Import.Register", StringComparison.OrdinalIgnoreCase))
            .ToList();

        var sample = samples?.LastOrDefault();
        if (sample == null)
        {
            return null;
        }

        var multiplier = sample.UnitOfMeasure?.Multiplier ?? 0;
        var scaled = sample.Value * (decimal)Math.Pow(10, multiplier);
        var unit = sample.UnitOfMeasure?.Unit?.Trim();

        if (!string.IsNullOrEmpty(unit) &&
            (unit.Equals("kWh", StringComparison.OrdinalIgnoreCase) ||
             unit.Equals("kW.h", StringComparison.OrdinalIgnoreCase)))
        {
            return scaled;
        }

        return scaled / 1000m;
    }

    private async Task<SessionDto> MapSessionDto(Guid sessionId, CancellationToken cancellationToken)
    {
        var session = await db.Sessions.AsNoTracking()
            .Include(x => x.Station)
            .Include(x => x.Connector)
            .FirstAsync(x => x.Id == sessionId, cancellationToken);

        decimal? energy = null;
        if (session.MeterStart.HasValue && session.MeterLast.HasValue)
        {
            energy = session.MeterLast.Value - session.MeterStart.Value;
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
            IsCurrent = session.EndedAt == null
        };
    }
}

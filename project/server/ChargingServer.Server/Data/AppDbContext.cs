using ChargingServer.Server.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace ChargingServer.Server.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<AccountEntity> Accounts => Set<AccountEntity>();
    public DbSet<StationEntity> Stations => Set<StationEntity>();
    public DbSet<ConnectorEntity> Connectors => Set<ConnectorEntity>();
    public DbSet<ChargingSessionEntity> Sessions => Set<ChargingSessionEntity>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AccountEntity>(e =>
        {
            e.HasIndex(x => x.Email).IsUnique();
            e.HasIndex(x => x.BindToken).IsUnique();
            e.Property(x => x.Email).HasMaxLength(256);
            e.Property(x => x.BindToken).HasMaxLength(64);
        });

        modelBuilder.Entity<StationEntity>(e =>
        {
            e.HasIndex(x => x.OcppChargePointId).IsUnique();
            e.Property(x => x.OcppChargePointId).HasMaxLength(128);
            e.Property(x => x.DisplayName).HasMaxLength(200);
            e.HasOne(x => x.Account).WithMany(x => x.Stations).HasForeignKey(x => x.AccountId).OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<ConnectorEntity>(e =>
        {
            e.HasIndex(x => new { x.StationId, x.EvseId, x.ConnectorNumber }).IsUnique();
            e.Property(x => x.Status).HasMaxLength(64);
            e.HasOne(x => x.Station).WithMany(x => x.Connectors).HasForeignKey(x => x.StationId).OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<ChargingSessionEntity>(e =>
        {
            e.HasIndex(x => new { x.AccountId, x.EndedAt });
            e.Property(x => x.OcppTransactionId).HasMaxLength(128);
            e.HasOne(x => x.Account).WithMany(x => x.Sessions).HasForeignKey(x => x.AccountId).OnDelete(DeleteBehavior.Cascade);
            e.HasOne(x => x.Station).WithMany(x => x.Sessions).HasForeignKey(x => x.StationId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne(x => x.Connector).WithMany(x => x.Sessions).HasForeignKey(x => x.ConnectorId).OnDelete(DeleteBehavior.Restrict);
        });
    }
}

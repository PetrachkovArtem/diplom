using ChargingServer.Server.Data.Entities;
using ChargingServer.Server.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace ChargingServer.Server.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(AppDbContext db, IConfiguration configuration, IPasswordHasher<AccountEntity> passwordHasher)
    {
        await db.Database.MigrateAsync();

        var email = configuration["Admin:Email"] ?? "admin@admin";
        var password = configuration["Admin:Password"] ?? "Admin123!";

        if (await db.Accounts.AnyAsync(x => x.Role == AccountRole.Admin))
        {
            return;
        }

        var account = new AccountEntity
        {
            Id = Guid.NewGuid(),
            Email = email.Trim().ToLowerInvariant(),
            Consent = true,
            Role = AccountRole.Admin,
            BindToken = await BindTokenGenerator.CreateUniqueAsync(db),
            CreatedAt = DateTime.UtcNow
        };
        account.PasswordHash = passwordHasher.HashPassword(account, password);

        db.Accounts.Add(account);
        await db.SaveChangesAsync();
    }
}

using ChargingServer.Server.Data;
using ChargingServer.Server.Data.Entities;
using ChargingServer.Server.Dtos;
using Microsoft.EntityFrameworkCore;

namespace ChargingServer.Server.Services;

public class AdminService(AppDbContext db, AuthService authService)
{
    public async Task<PagedResult<AdminUserDto>> ListUsersAsync(string? email, int page, int pageSize)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 100);

        var query = db.Accounts.AsNoTracking().Where(x => x.Role == AccountRole.User);
        if (!string.IsNullOrWhiteSpace(email))
        {
            var filter = email.Trim().ToLowerInvariant();
            query = query.Where(x => x.Email.Contains(filter));
        }

        query = query.OrderByDescending(x => x.CreatedAt);
        var total = await query.CountAsync();
        var items = await query.Skip((page - 1) * pageSize).Take(pageSize)
            .Select(x => new AdminUserDto
            {
                Id = x.Id,
                Email = x.Email,
                IsBlocked = x.IsBlocked,
                CreatedAt = x.CreatedAt,
                Role = x.Role.ToString()
            }).ToListAsync();

        return new PagedResult<AdminUserDto>
        {
            Items = items,
            Page = page,
            PageSize = pageSize,
            Total = total
        };
    }

    public async Task SetBlockedAsync(Guid userId, bool isBlocked)
    {
        var account = await db.Accounts.FirstOrDefaultAsync(x => x.Id == userId && x.Role == AccountRole.User) ?? throw new InvalidOperationException("Пользователь не найден.");

        account.IsBlocked = isBlocked;
        await db.SaveChangesAsync();
    }

    public Task ResetPasswordAsync(Guid userId, ResetPasswordRequest request)
    {
        return authService.ResetPasswordAsync(userId, request.NewPassword, request.NewPasswordRepeat);
    }
}

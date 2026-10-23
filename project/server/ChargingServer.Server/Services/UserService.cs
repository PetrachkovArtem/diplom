using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ChargingServer.Server.Data;
using ChargingServer.Server.Data.Entities;
using ChargingServer.Server.Dtos;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace ChargingServer.Server.Services;

public class UserService(AppDbContext db, IConfiguration configuration, IPasswordHasher<AccountEntity> passwordHasher)
{
    public async Task<LoginResponse> RegisterAsync(RegisterRequest request)
    {
        if (!request.Consent)
        {
            throw new InvalidOperationException("Необходимо согласие на обработку персональных данных.");
        }

        var email = NormalizeEmail(request.Email);
        if (await db.Accounts.AnyAsync(x => x.Email == email))
        {
            throw new InvalidOperationException("Учётная запись с таким email уже существует.");
        }

        ValidatePassword(request.Password);

        var account = new AccountEntity
        {
            Id = Guid.NewGuid(),
            Email = email,
            Consent = true,
            Role = AccountRole.User,
            BindToken = await BindTokenGenerator.CreateUniqueAsync(db),
            CreatedAt = DateTime.UtcNow
        };
        account.PasswordHash = passwordHasher.HashPassword(account, request.Password);

        db.Accounts.Add(account);
        await db.SaveChangesAsync();
        return CreateLoginResponse(account);
    }

    public async Task<LoginResponse> LoginAsync(LoginRequest request)
    {
        var email = NormalizeEmail(request.Email);
        var account = await db.Accounts.FirstOrDefaultAsync(x => x.Email == email)
            ?? throw new InvalidOperationException("Неверный email или пароль.");

        if (account.IsBlocked)
        {
            throw new InvalidOperationException("Учётная запись заблокирована.");
        }

        if (!VerifyPassword(account, request.Password))
        {
            throw new InvalidOperationException("Неверный email или пароль.");
        }

        return CreateLoginResponse(account);
    }

    public async Task ChangePasswordAsync(Guid accountId, ChangePasswordRequest request)
    {
        var account = await db.Accounts.FindAsync(accountId)
            ?? throw new InvalidOperationException("Учётная запись не найдена.");

        if (!VerifyPassword(account, request.CurrentPassword))
        {
            throw new InvalidOperationException("Текущий пароль указан неверно.");
        }

        if (request.NewPassword != request.NewPasswordRepeat)
        {
            throw new InvalidOperationException("Новый пароль и подтверждение не совпадают.");
        }

        ValidatePassword(request.NewPassword);
        account.PasswordHash = passwordHasher.HashPassword(account, request.NewPassword);
        await db.SaveChangesAsync();
    }

    public async Task ResetPasswordAsync(Guid accountId, string newPassword, string repeat)
    {
        if (newPassword != repeat)
        {
            throw new InvalidOperationException("Новый пароль и подтверждение не совпадают.");
        }

        ValidatePassword(newPassword);
        var account = await db.Accounts.FindAsync(accountId)
            ?? throw new InvalidOperationException("Учётная запись не найдена.");

        account.PasswordHash = passwordHasher.HashPassword(account, newPassword);
        await db.SaveChangesAsync();
    }

    private bool VerifyPassword(AccountEntity account, string password)
    {
        var result = passwordHasher.VerifyHashedPassword(account, account.PasswordHash, password);
        return result is PasswordVerificationResult.Success or PasswordVerificationResult.SuccessRehashNeeded;
    }

    private LoginResponse CreateLoginResponse(AccountEntity account)
    {
        var key = configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key не задан.");
        var issuer = configuration["Jwt:Issuer"] ?? "ChargingServer";
        var audience = configuration["Jwt:Audience"] ?? "ChargingServer";
        var expiresMinutes = int.TryParse(configuration["Jwt:ExpiresMinutes"], out var m) ? m : 1440;

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, account.Id.ToString()),
            new(ClaimTypes.NameIdentifier, account.Id.ToString()),
            new(JwtRegisteredClaimNames.Email, account.Email),
            new(ClaimTypes.Role, account.Role.ToString()),
            new("bind_token", account.BindToken)
        };

        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer,
            audience,
            claims,
            expires: DateTime.UtcNow.AddMinutes(expiresMinutes),
            signingCredentials: credentials);

        return new LoginResponse
        {
            AccessToken = new JwtSecurityTokenHandler().WriteToken(token),
            Email = account.Email,
            Role = account.Role.ToString(),
            BindToken = account.BindToken
        };
    }

    private static string NormalizeEmail(string email) => email.Trim().ToLowerInvariant();

    private static void ValidatePassword(string password)
    {
        if (string.IsNullOrWhiteSpace(password) || password.Length < 6)
        {
            throw new InvalidOperationException("Пароль должен содержать не менее 6 символов.");
        }
    }
}

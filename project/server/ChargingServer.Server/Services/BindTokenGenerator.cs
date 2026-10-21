using System.Security.Cryptography;
using ChargingServer.Server.Data;
using Microsoft.EntityFrameworkCore;

namespace ChargingServer.Server.Services;

/// <summary>
/// Короткий код привязки станции (удобно вводить на зарядке).
/// Без неоднозначных символов: 0/O, 1/I/L.
/// </summary>
public static class BindTokenGenerator
{
    private const string Alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private const int Length = 8;

    public static string Create()
    {
        Span<char> buffer = stackalloc char[Length];
        Span<byte> bytes = stackalloc byte[Length];
        RandomNumberGenerator.Fill(bytes);

        for (var i = 0; i < Length; i++)
        {
            buffer[i] = Alphabet[bytes[i] % Alphabet.Length];
        }

        return new string(buffer);
    }

    public static async Task<string> CreateUniqueAsync(AppDbContext db, CancellationToken cancellationToken = default)
    {
        for (var attempt = 0; attempt < 32; attempt++)
        {
            var token = Create();
            if (!await db.Accounts.AnyAsync(x => x.BindToken == token, cancellationToken))
            {
                return token;
            }
        }

        throw new InvalidOperationException("Не удалось сгенерировать уникальный код привязки станции.");
    }
}

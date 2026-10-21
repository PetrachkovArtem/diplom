using System.Security.Claims;

namespace ChargingServer.Server.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetAccountId(this ClaimsPrincipal user)
    {
        var value = user.FindFirstValue(ClaimTypes.NameIdentifier)
                    ?? user.FindFirstValue("sub")
                    ?? throw new UnauthorizedAccessException();
        return Guid.Parse(value);
    }
}

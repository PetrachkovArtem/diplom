using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace ChargingServer.Server.Hubs;

[Authorize]
public class SessionHub : Hub
{
    public static string UserGroup(Guid accountId) => $"user:{accountId}";

    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier)
                     ?? Context.User?.FindFirstValue("sub");
        if (Guid.TryParse(userId, out var accountId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, UserGroup(accountId));
        }

        await base.OnConnectedAsync();
    }
}

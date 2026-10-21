using ChargingServer.Server.Dtos;
using ChargingServer.Server.Extensions;
using ChargingServer.Server.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargingServer.Server.Controllers;

[ApiController]
[Authorize(Roles = "Admin")]
[Route("api/admin")]
public class AdminController(AdminService adminService, AuthService authService) : Controller
{
    [HttpGet("users")]
    public async Task<ActionResult<PagedResult<AdminUserDto>>> Users([FromQuery] string? email, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        return Ok(await adminService.ListUsersAsync(email, page, pageSize));
    }

    [HttpPost("users/{id}/block")]
    public async Task<IActionResult> Block(Guid id, BlockUserRequest request)
    {

        await adminService.SetBlockedAsync(id, request.IsBlocked);
        return Ok();
    }

    [HttpPost("users/{id}/reset-password")]
    public async Task<IActionResult> ResetPassword(Guid id, ResetPasswordRequest request)
    {

        await adminService.ResetPasswordAsync(id, request);
        return Ok();
    }

    [HttpPost("me/password")]
    public async Task<IActionResult> ChangeOwnPassword(ChangePasswordRequest request)
    {
        try
        {
            await authService.ChangePasswordAsync(User.GetAccountId(), request);
            return Ok();
        }
        catch (InvalidOperationException)
        {
            return BadRequest();
        }
    }
}

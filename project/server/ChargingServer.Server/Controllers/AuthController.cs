using ChargingServer.Server.Data;
using ChargingServer.Server.Dtos;
using ChargingServer.Server.Extensions;
using ChargingServer.Server.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargingServer.Server.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(AuthService authService, AppDbContext db) : Controller
{
    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Register(RegisterRequest request)
    {
        try
        {
            return Ok(await authService.RegisterAsync(request));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new
            {
                message = ex.Message
            });
        }
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponse>> Login(LoginRequest request)
    {
        try
        {
            return Ok(await authService.LoginAsync(request));
        }
        catch (InvalidOperationException)
        {
            return Unauthorized();
        }
    }

    [HttpGet("me")]
    public async Task<ActionResult<MeResponse>> Get()
    {
        var id = User.GetAccountId();
        var account = await db.Accounts.FindAsync(id);
        if (account == null)
        {
            return NotFound();
        }

        return Ok(new MeResponse
        {
            Id = account.Id,
            Email = account.Email,
            Role = account.Role.ToString(),
            BindToken = account.BindToken
        });
    }

    [HttpPost("password")]
    public async Task<IActionResult> ChangePassword(ChangePasswordRequest request)
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

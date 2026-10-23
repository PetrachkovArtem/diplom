using ChargingServer.Server.Data;
using ChargingServer.Server.Dtos;
using ChargingServer.Server.Extensions;
using ChargingServer.Server.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargingServer.Server.Controllers;

[ApiController]
[Route("api/user")]
public class UserController(UserService userService, AppDbContext db) : Controller
{
    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponse>> Register(RegisterRequest request)
    {
        try
        {
            return Ok(await userService.RegisterAsync(request));
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
    public async Task<ActionResult<LoginResponse>> Login(LoginRequest request)
    {
        try
        {
            return Ok(await userService.LoginAsync(request));
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
            BindToken = account.BindToken,
            PricePerKwh = account.PricePerKwh
        });
    }

    [HttpPatch("profile")]
    public async Task<ActionResult<MeResponse>> UpdateProfile([FromBody] UpdateProfileRequest request)
    {
        if (request.PricePerKwh < 0)
        {
            return BadRequest(new { message = "Стоимость 1 кВт·ч не может быть отрицательной." });
        }

        var id = User.GetAccountId();
        var account = await db.Accounts.FindAsync(id);
        if (account == null)
        {
            return NotFound();
        }

        account.PricePerKwh = request.PricePerKwh;
        await db.SaveChangesAsync();

        return Ok(new MeResponse
        {
            Id = account.Id,
            Email = account.Email,
            Role = account.Role.ToString(),
            BindToken = account.BindToken,
            PricePerKwh = account.PricePerKwh
        });
    }

    [HttpPost("password")]
    public async Task<IActionResult> ChangePassword(ChangePasswordRequest request)
    {
        try
        {
            await userService.ChangePasswordAsync(User.GetAccountId(), request);
            return Ok();
        }
        catch (InvalidOperationException)
        {
            return BadRequest();
        }
    }
}

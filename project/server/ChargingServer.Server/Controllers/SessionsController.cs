using ChargingServer.Server.Dtos;
using ChargingServer.Server.Extensions;
using ChargingServer.Server.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargingServer.Server.Controllers;

[ApiController]
[Authorize(Roles = "User")]
[Route("api/sessions")]
public class SessionsController(SessionService sessionService) : Controller
{
    [HttpPost("start")]
    public async Task<ActionResult<SessionDto>> Start([FromBody] StartSessionRequest request)
    {
        try
        {
            return Ok(await sessionService.StartAsync(User.GetAccountId(), request));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("stop")]
    public async Task<ActionResult<SessionDto>> Stop([FromBody] StopSessionRequest request)
    {
        try
        {
            return Ok(await sessionService.StopAsync(User.GetAccountId(), request.StationId));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("current")]
    public async Task<ActionResult<SessionDto?>> Current([FromQuery] Guid stationId)
    {
        try
        {
            return Ok(await sessionService.GetCurrentAsync(User.GetAccountId(), stationId));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("history")]
    public async Task<ActionResult<PagedResult<SessionDto>>> History([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        return Ok(await sessionService.GetHistoryAsync(User.GetAccountId(), page, pageSize));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<SessionDto>> Get(Guid id)
    {
        return Ok(await sessionService.GetByIdAsync(User.GetAccountId(), id));
    }
}

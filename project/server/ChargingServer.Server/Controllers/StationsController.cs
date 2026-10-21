using ChargingServer.Server.Dtos;
using ChargingServer.Server.Extensions;
using ChargingServer.Server.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ChargingServer.Server.Controllers;

[ApiController]
[Authorize(Roles = "User")]
[Route("api/stations")]
public class StationsController(StationService stationService) : Controller
{
    [HttpGet]
    public async Task<ActionResult<List<StationDto>>> List()
    {
        return Ok(await stationService.ListAsync(User.GetAccountId()));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<StationDto>> Get(Guid id)
    {
        var station = await stationService.GetAsync(User.GetAccountId(), id);
        return station == null ? NotFound() : Ok(station);
    }

    [HttpGet("bind-url")]
    public async Task<ActionResult<BindUrlResponse>> BindUrl()
    {
        return Ok(await stationService.GetBindUrlAsync(User.GetAccountId()));
    }

    [HttpPatch("{id}")]
    public async Task<ActionResult<StationDto>> Rename(Guid id, [FromBody] RenameStationRequest request)
    {
        try
        {
            return Ok(await stationService.RenameAsync(User.GetAccountId(), id, request.DisplayName));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        try
        {
            await stationService.DeleteAsync(User.GetAccountId(), id);
            return Ok();
        }
        catch (InvalidOperationException)
        {
            return BadRequest();
        }
    }
}

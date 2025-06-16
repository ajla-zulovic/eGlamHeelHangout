using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model.Utilities;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eGlamHeelHangout.Controllers
{
 
    [ApiController]
    [Route("[controller]")]
    
    public class GiveawayController : BaseController<Model.Giveaways, Model.SearchObjects.GiveawaySearchObject>
    {
        private readonly IGiveawayService _giveawayService;

        public GiveawayController(ILogger<BaseController<Giveaways, Model.SearchObjects.GiveawaySearchObject>> logger, IGiveawayService service) : base(logger, service)
        {
            _giveawayService = service;
        }

        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Insert([FromBody] GiveawayInsertRequest request)
        {
            var result = await _giveawayService.Insert(request);
            return Ok(result);
        }


        [HttpGet("active")]
        [AllowAnonymous]
        public async Task<IActionResult> GetActive()
        {
            var result = await _giveawayService.GetActive();
            return Ok(result);
        }


        [HttpPost("participate")]
        [Authorize]
        public async Task<IActionResult> Participate([FromBody] GiveawayParticipantInsertRequest request)
        {
            var username = HttpContext.User.Identity?.Name;
            if (string.IsNullOrEmpty(username)) return Unauthorized();

            var result = await _giveawayService.AddParticipant(username, request);
            return Ok(result);
        }


        [HttpPost("{id}/pick-winner")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> PickWinner(int id)
        {
            var result = await _giveawayService.PickWinner(id);
            if (result == null) return NotFound("No participants found.");

            return Ok(result);
        }


        [HttpGet("admin/filter")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetFiltered([FromQuery] bool? isActive)
        {
            var list = await _giveawayService.GetFiltered(isActive);

            var result = new PagedResult<Model.Giveaways>
            {
                Count = list.Count,
                Result = list
            };

            return Ok(result);
        }


        [HttpPost("{giveawayId}/notify-winner/{winnerUserId}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> NotifyWinner(int giveawayId, int winnerUserId)
        {
            await _giveawayService.NotifyWinner(giveawayId, winnerUserId);
            return Ok();
        }

        [HttpGet("user/notifications")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> GetUserNotifications()
        {
            var activeGiveaways = await _giveawayService.GetActive();
            var lastWinnerNotification = await _giveawayService.GetLastWinnerNotification();

            return Ok(new
            {
                ActiveGiveaways = activeGiveaways,
                LastWinnerNotification = lastWinnerNotification
            });
        }

    }

}


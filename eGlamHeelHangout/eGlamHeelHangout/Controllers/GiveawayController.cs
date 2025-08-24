using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model.Utilities;
using eGlamHeelHangout.Service;
using eGlamHeelHangout.Service.SignalR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

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
        [Authorize]
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
            try
            {
                var result = await _giveawayService.PickWinner(id);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
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
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<IActionResult> Delete(int id)
        {
            try
            {
                var result = await _giveawayService.DeleteIfAllowed(id);
                return Ok(new { message = "Giveaway deleted successfully." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("user/winner-notifications")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> GetWinnerNotifications()
        {
            var username = HttpContext.User.Identity?.Name;
            if (string.IsNullOrEmpty(username)) return Unauthorized();

            var result = await _giveawayService.GetWinnerNotificationsForUser(username);
            return Ok(result);
        }

        [HttpGet("user/finished-with-winner")]
        [Authorize]
        public async Task<IActionResult> GetFinishedWithWinner()
        {
            var list = await _giveawayService.GetFinishedWithWinner();
            if (list == null || !list.Any())
                return NotFound("There are no finished giveaway with winner.");

            return Ok(list);
        }




    }

}


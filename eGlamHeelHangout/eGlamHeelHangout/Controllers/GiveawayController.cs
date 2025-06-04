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
      

    }

}


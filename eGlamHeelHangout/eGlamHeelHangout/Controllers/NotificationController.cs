using eGlamHeelHangout.Model;
using Microsoft.AspNetCore.SignalR;
using eGlamHeelHangout.Service.SignalR;
using Microsoft.AspNetCore.Mvc;

namespace eGlamHeelHangout.Controllers
{


    [Route("notifications")]
    [ApiController]
    public class NotificationController : ControllerBase
    {
        private readonly IHubContext<GiveawayHub> _hubContext;

        public NotificationController(IHubContext<GiveawayHub> hubContext)
        {
            _hubContext = hubContext;
        }

        [HttpPost("giveaway")]
        public async Task<IActionResult> NotifyGiveaway([FromBody] GiveawayNotificationDTO dto)
        {
            await _hubContext.Clients.All.SendAsync("ReceiveGiveaway", dto);
            return Ok();
            Console.WriteLine("SignalR NotifyGiveaway triggered");

        }

        [HttpPost("winner")]
        public async Task<IActionResult> NotifyWinner([FromBody] WinnerNotification dto)
        {
            await _hubContext.Clients.All.SendAsync("ReceiveWinner", dto);
            return Ok();
        }
    }
}

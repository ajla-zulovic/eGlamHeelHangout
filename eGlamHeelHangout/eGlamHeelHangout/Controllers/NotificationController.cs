using eGlamHeelHangout.Model;
using Microsoft.AspNetCore.SignalR;
using eGlamHeelHangout.Service.SignalR;
using Microsoft.AspNetCore.Mvc;
using eGlamHeelHangout.Service.Database;
using Microsoft.AspNetCore.Authorization;

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
        //[Authorize]
        public async Task<IActionResult> NotifyGiveaway([FromBody] GiveawayNotificationDTO dto)
        {
            await _hubContext.Clients.All.SendAsync("ReceiveGiveaway", dto);
            return Ok();
            Console.WriteLine("SignalR NotifyGiveaway triggered");

        }

        [HttpPost("winner")]
        //[Authorize]
        public async Task<IActionResult> NotifyWinner([FromBody] WinnerNotification dto)
        {
            await _hubContext.Clients.All.SendAsync("ReceiveWinner", dto);
            return Ok();
        }

        [HttpPost("product")]
       // [Authorize]
        public async Task<IActionResult> NotifyProduct([FromBody] ProductNotificationDTO dto)
        {
            await _hubContext.Clients.All.SendAsync("ReceiveProduct", dto);
            Console.WriteLine("Notifikacija stigla u ProductNotificationController: " + dto.Name);

            return Ok();
        }
        [HttpPost("discount")]
        //[Authorize]
        public async Task<IActionResult> NotifyDiscount([FromBody] DiscountNotification dto)
        {
            Console.WriteLine($"Notifikacija stigla u DiscountNotificationController: {dto.ProductName} - {dto.DiscountPercentage}%");


            await _hubContext.Clients.All.SendAsync("ReceiveDiscount", new
            {
                notificationId = 0, 
                productId = dto.ProductId,
                productName = dto.ProductName,
                discountPercentage = dto.DiscountPercentage,
                image = dto.Image,
                message = $"New Sales! {dto.DiscountPercentage}% OFF on {dto.ProductName}",
                dateSent = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss")
            });

            return Ok();
        }



    }
}

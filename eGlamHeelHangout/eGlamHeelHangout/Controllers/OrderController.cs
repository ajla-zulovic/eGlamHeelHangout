using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace eGlamHeelHangout.Controllers
{

    [ApiController]
    [Route("[controller]")]
    public class OrderController : BaseCRUDController<Model.OrderDTO, OrderSearchObject, Model.Requests.OrderInsertRequest, object>
    {
        private readonly IOrderService _orderService;

        public OrderController(
             ILogger<BaseController<OrderDTO, OrderSearchObject>> logger,
             IOrderService service)
         : base(logger, service)
                {
            _orderService = service;
        }

        [HttpPost("custom-create")]
        [Authorize(Roles = "User")]
        public async Task<ActionResult<OrderDTO>> CreateOrder([FromBody] OrderInsertRequest request)
        {
            var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == "id")?.Value;
            if (string.IsNullOrEmpty(userIdClaim))
                return Unauthorized();

            request.UserId = int.Parse(userIdClaim);
            var result = await _service.Insert(request);
            return Ok(result);
        }
        [HttpGet("my-orders")]
        [Authorize(Roles = "User")]
        public async Task<ActionResult<List<OrderDTO>>> GetMyOrders()
        {
            var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == "id")?.Value;
            if (string.IsNullOrEmpty(userIdClaim))
                return Unauthorized();

            var userId = int.Parse(userIdClaim);
            var search = new OrderSearchObject { UserId = userId };
            var result = await _service.Get(search);
            return Ok(result.Result);
        }

        [HttpPut("{orderId}/status")] 
        [Authorize(Roles = "User,Admin")]
        public async Task<ActionResult<string>> UpdateOrderStatus(int orderId, [FromBody] string newStatus)
        {
            try
            {
                var resultMessage = await _orderService.UpdateOrderStatusAsync(orderId, newStatus);
                return Ok(resultMessage); 
            }
            catch (Exception ex)
            {
            
                return BadRequest(ex.Message); 
            }
        }

    }
}
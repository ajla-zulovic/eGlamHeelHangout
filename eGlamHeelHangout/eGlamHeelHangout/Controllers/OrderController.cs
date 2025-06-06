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
        public OrderController(
             ILogger<BaseController<OrderDTO, OrderSearchObject>> logger,
             IOrderService service)
         : base(logger, service)
                { }

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
    }
}
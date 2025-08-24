
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;

using eGlamHeelHangout.Model.Payment;
using eGlamHeelHangout.Services;
using Microsoft.AspNetCore.Mvc;
using eGlamHeelHangout.Model.Utilities;
using Microsoft.Extensions.Options;

namespace eGlamHeelHangout.Controllers
{


    [ApiController]
    [Route("[controller]")]
    public class StripeController : ControllerBase
    {
        private readonly IStripeService _stripeService;
        private readonly StripeSettings _stripeSettings;

        public StripeController(IStripeService stripeService, IOptions<StripeSettings> stripeSettings)
        {
            _stripeService = stripeService;
            _stripeSettings = stripeSettings.Value;
        }

        [HttpPost("create-intent")]
  
        public async Task<ActionResult<IntentResponseDTO>> CreateIntent([FromBody] PaymentCreateDTO request)
        {
            var result = await _stripeService.CreatePaymentIntent(request);
            return Ok(result);
        }

        [HttpPost("confirm")]

        public async Task<ActionResult<PaymentResponseDTO>> ConfirmPayment([FromBody] PaymentCreateDTO request)
        {
            var result = await _stripeService.ConfirmPayment(request);
            return Ok(result);
        }

        [HttpPost("refund")]
    
        public async Task<IActionResult> Refund([FromQuery] string paymentIntentId)
        {
            await _stripeService.CreateRefundAsync(paymentIntentId);
            return Ok(new { message = "Refund created successfully." });
        }
        [HttpGet("config")]
        
        public IActionResult GetStripeConfig()
        {
            return Ok(new { publishableKey = _stripeSettings.PublishableKey });
        }

    }

}


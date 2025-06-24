using eGlamHeelHangout.Model.Payment;
using eGlamHeelHangout.Model.Utilities;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Services;
using eGlamHeelHangout.Model.Payment;
using eGlamHeelHangout.Model.Utilities;
using eGlamHeelHangout.Services;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eGlamHeelHangout.Service;

namespace eGlamHeelHangout.Services
{
    public class StripeService : IStripeService
    {
        private readonly StripeSettings _stripeSettings;
        private readonly IOrderService _orderService;

        public StripeService(IOptions<StripeSettings> stripeSettings,IOrderService orderService)
        {
            _stripeSettings = stripeSettings.Value;
            StripeConfiguration.ApiKey = _stripeSettings.SecretKey;
            _orderService = orderService;
        }

        public async Task CreateRefundAsync(string paymentIntentId)
        {
            var refundService = new RefundService();

            var options = new RefundCreateOptions
            {
                PaymentIntent = paymentIntentId
            };

            await refundService.CreateAsync(options);
        }

        public async Task<PaymentResponseDTO> ConfirmPayment(PaymentCreateDTO request)
        {
            var intentOptions = new PaymentIntentCreateOptions
            {
                Amount = request.TotalAmount,
                Currency = "eur",
                PaymentMethodTypes = new List<string> { "card" },
                Metadata = new Dictionary<string, string>
        {
            { "order_id", request.OrderId.ToString() },
            { "username", request.Username },
        },
            };

            var service = new PaymentIntentService();

            var intent = await service.CreateAsync(intentOptions);

            var confirmOptions = new PaymentIntentConfirmOptions
            {
                PaymentMethod = request.PaymentMethodId,
            };

            var response = new PaymentResponseDTO { PaymentIntentId = intent.Id };

            try
            {
                var confirmation = await service.ConfirmAsync(intent.Id, confirmOptions);

                response.Message = confirmation.Status;

                if (!string.IsNullOrEmpty(request.OrderId.ToString()))
                {
                    if (confirmation.Status == "succeeded")
                    {
                        await _orderService.UpdateOrderStatus(request.OrderId!.Value, "Shipped");
                    }
                    else if (confirmation.Status == "failed")
                    {
                        await _orderService.UpdateOrderStatus(request.OrderId!.Value, "Payment Failed");
                    }
                }
            }
            catch (StripeException ex)
            {
                response.Message = ex.StripeError?.Message ?? "An error occurred while processing the payment.";
            }
            catch (UserException ex)
            {
                response.Message = $"An unexpected error occurred: {ex.Message}";
            }

            return response;
        }


        public async Task<IntentResponseDTO> CreatePaymentIntent(PaymentCreateDTO request)
        {
            var metadata = new Dictionary<string, string>();

            if (!string.IsNullOrEmpty(request.Username))

            {
                metadata.Add("user", request.Username!);
            }
            if (request.OrderId.HasValue)
            {
                metadata.Add("order_id", request.OrderId.Value.ToString());
            }
            else if (request.ReservationId.HasValue)
            {
                metadata.Add("reservation_id", request.ReservationId.Value.ToString());
            }

            var options = new PaymentIntentCreateOptions
            {
                Amount = request.TotalAmount,
                Currency = "eur",
                PaymentMethodTypes = new List<string> { "card" },
                CaptureMethod = "automatic",
                Metadata = metadata
            };

            var service = new PaymentIntentService();
            var paymentintent = await service.CreateAsync(options);

            var response = new IntentResponseDTO
            {
                PaymentIntentId = paymentintent.Id,
                clientSecret = paymentintent.ClientSecret
            };

            return response;
        }
    }
}
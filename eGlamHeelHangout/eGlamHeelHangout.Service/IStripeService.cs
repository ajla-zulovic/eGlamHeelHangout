using eGlamHeelHangout.Model.Payment;
using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Services
{
    public interface IStripeService
    {
        Task<PaymentResponseDTO> ConfirmPayment(PaymentCreateDTO request);
        Task<IntentResponseDTO> CreatePaymentIntent(PaymentCreateDTO request);
        Task CreateRefundAsync(string paymentIntentId);
    }
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Payment
{
    public class IntentResponseDTO
    {
        public string PaymentIntentId { get; set; }
        public string clientSecret { get; set; }
    }
}
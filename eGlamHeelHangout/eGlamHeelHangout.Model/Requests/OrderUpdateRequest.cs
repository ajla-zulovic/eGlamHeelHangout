using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
    public class OrderUpdateRequest
    {
        public int OrderId { get; set; }
        public string OrderStatus { get; set; } = string.Empty;
    }
}

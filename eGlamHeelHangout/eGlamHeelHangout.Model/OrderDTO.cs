using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
    public class OrderDTO
    {
        public int OrderId { get; set; }
        public decimal TotalPrice { get; set; }
        public string OrderStatus { get; set; } = string.Empty;
        public DateTime? OrderDate { get; set; }
        public string PaymentMethod { get; set; } = string.Empty;

        public string? Username { get; set; } // prikazati Username

        public List<OrderItemDTO> Items { get; set; } = new();
    }
}

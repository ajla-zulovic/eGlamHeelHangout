using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service.Database
{
    public partial class Order
    {
        public Order()
        {
            OrderItems = new HashSet<OrderItem>();
        }

        public int OrderId { get; set; }
        public int UserId { get; set; }
        public decimal TotalPrice { get; set; }
        public string OrderStatus { get; set; } = null!;
        public DateTime? OrderDate { get; set; }
        public string PaymentMethod { get; set; } = null!;

        public virtual User User { get; set; } = null!;
        public virtual ICollection<OrderItem> OrderItems { get; set; }
    }
}

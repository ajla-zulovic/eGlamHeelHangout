using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service.Database
{
    public partial class OrderItem
    {
        public int OrderItemId { get; set; }
        public int OrderId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public decimal PricePerUnit { get; set; }
        public int ProductSizeId { get; set; }  
        public virtual ProductSize ProductSize { get; set; } = null!;

        public virtual Order Order { get; set; } = null!;
        public virtual Product Product { get; set; } = null!;
    }
}

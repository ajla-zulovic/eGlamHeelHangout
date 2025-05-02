using eGlamHeelHangout.Service.Database;
using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service
{
    public partial class ProductSize
    {
        public int ProductSizeId { get; set; }
        public int ProductId { get; set; }
        public int Size { get; set; }
        public int StockQuantity { get; set; }
         public virtual Product Product { get; set; } = null!;
  }
}

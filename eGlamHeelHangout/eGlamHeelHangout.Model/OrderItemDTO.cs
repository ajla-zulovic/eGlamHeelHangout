﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
    public class OrderItemDTO
    {
        public int ProductId { get; set; }
        public string? ProductName { get; set; } 
        public int Quantity { get; set; }
        public decimal PricePerUnit { get; set; }
        public int Size { get; set; }
        public int ProductSizeId { get; set; }
    }
}

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
    public class ProductSizes
    {
        [Range(36, 46, ErrorMessage = "Size must be between 36 and 46.")]
        public int Size { get; set; }
        [Range(0, 20, ErrorMessage = "Stock quantity must be a positive number.")]
        public int StockQuantity { get; set; }
    }
}

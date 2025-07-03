using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
    public class DiscountNotification
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = null!;
        public int DiscountPercentage { get; set; }
        public byte[]? Image { get; set; }
    }
}

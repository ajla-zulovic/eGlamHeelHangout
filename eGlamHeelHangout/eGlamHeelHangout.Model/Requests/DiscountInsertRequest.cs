using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
    public class DiscountInsertRequest
    {
        public int ProductId { get; set; }
        [Range(0, 70, ErrorMessage = "Discount must be between 0 and 70.")]
        public int DiscountPercentage { get; set; }

        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }
    }
}

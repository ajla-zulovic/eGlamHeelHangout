using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
    public class OrderInsertRequest
    {
        public int UserId { get; set; }
        [Required]
        public decimal TotalPrice { get; set; }
        [Required]
        public string OrderStatus { get; set; }
     
        public DateTime OrderDate { get; set; } = DateTime.Now;
        [Required]
        public List<OrderItemInsertRequest> Items { get; set; } = new();
        [Required]
        public string PaymentMethod { get; set; } = "stripe";
        [Required]
        public string FullName { get; set; }

        [Required]
        [EmailAddress]
        [RegularExpression(
       @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
       ErrorMessage = "Invalid email format"
   )]
        public string Email { get; set; }

        [Required]
        public string Address { get; set; }

        [Required]
        public string City { get; set; }

        [Required]
        [RegularExpression(@"^[A-Za-z0-9 \-]{3,10}$", ErrorMessage = "Invalid postal code format.")]
        public string PostalCode { get; set; }

        [Required]
        [RegularExpression(
        @"^\+?[0-9]{6,15}$",
        ErrorMessage = "Invalid phone number format")]
        public string PhoneNumber { get; set; }
    }
}
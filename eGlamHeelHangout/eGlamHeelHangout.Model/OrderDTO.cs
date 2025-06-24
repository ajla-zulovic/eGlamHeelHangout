using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
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
        ErrorMessage = "Invalid phone number format"
    )]
        public string PhoneNumber { get; set; }
    }
}

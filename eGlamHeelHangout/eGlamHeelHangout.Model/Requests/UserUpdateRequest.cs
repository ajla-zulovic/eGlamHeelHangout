using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
  public class UserUpdateRequest
  {
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
        [Required(ErrorMessage = "Email is required")]
        [RegularExpression(
        @"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
        ErrorMessage = "Invalid email format"
    )]
        public string Email { get; set; } = null!;

        [Required(ErrorMessage = "Phone number is required")]
        [RegularExpression(
            @"^\+?[0-9]{6,15}$",
            ErrorMessage = "Invalid phone number format"
        )]
        public string? PhoneNumber { get; set; }
    public string? Address { get; set; }
    public byte[]? ProfileImage { get; set; }
    public DateTime? DateOfBirth { get; set; }


    }
}

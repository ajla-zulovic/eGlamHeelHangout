using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
  public class UsersInsertRequest
  {
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Username { get; set; } = null!;
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


        public string Password { get; set; }
    //cisto potvrda da li je korisnik unio isti password i drugi put
    [Compare("Password", ErrorMessage = "Passwords do not match")]
    public string PasswordPotvrda { get; set; }
  
    public int RoleId { get; set; }
  }
}

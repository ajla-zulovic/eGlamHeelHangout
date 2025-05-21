using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
  public partial  class Users
  {
    public int UserId { get; set; }
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Username { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public string? Address { get; set; }
    public byte[]? ProfileImage { get; set; }
    public DateTime? DateOfBirth { get; set; }

        public virtual ICollection<UsersRoles> UsersRoles { get; } = new List<UsersRoles>();

    
  }
}

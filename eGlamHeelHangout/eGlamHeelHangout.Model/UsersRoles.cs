using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
  public partial class UsersRoles
  {
 
    public int UserId { get; set; }
    public int RoleId { get; set; }
    public DateTime DateChange { get; set; }
    public virtual Roles Role { get; set; } = null!;
  }
}

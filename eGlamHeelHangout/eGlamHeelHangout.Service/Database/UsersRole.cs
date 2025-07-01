using eGlamHeelHangout.Service.Database;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace eGlamHeelHangout.Service.Database
{
    public partial class UsersRole
    {
        
        public int UserId { get; set; }
        public int RoleId { get; set; }
        public DateTime DateChange { get; set; }

       public virtual User User { get; set; } = null!;
       public virtual Role Role { get; set; } = null!;
   

    }
}

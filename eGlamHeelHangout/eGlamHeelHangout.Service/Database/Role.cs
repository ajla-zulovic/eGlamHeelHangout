using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service.Database
{
    public partial class Role
    {
        public Role()
        {
            UsersRoles = new HashSet<UsersRole>();
        }

        public int RoleId { get; set; }
        public string RoleName { get; set; } = null!;

        public virtual ICollection<UsersRole> UsersRoles { get; set; }
    }
}

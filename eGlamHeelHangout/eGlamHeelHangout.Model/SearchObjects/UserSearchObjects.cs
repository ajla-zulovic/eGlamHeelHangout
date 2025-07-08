using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.SearchObjects
{
  public class UserSearchObjects:BaseSearchObject
  {
    public bool? IsRolseIncluded { get; set; }
    public string? SearchText { get; set; }
    }
}

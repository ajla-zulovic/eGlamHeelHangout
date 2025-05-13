using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
  public class ProductsUpdateRequest
  {
    public string? Name{ get; set; }
    public string? Description { get; set; }
    public decimal? Price { get; set; }
    public byte[]? Image { get; set; }
  }
}

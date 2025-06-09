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
    public int? CategoryID { get; set; }   
    public string? Material { get; set; }  
    public string? Color { get; set; }     
    public double? HeelHeight { get; set; } 

        public List<ProductSizeUpdateModel>? Sizes { get; set; }

        public class ProductSizeUpdateModel
        {
            public int ProductSizeId { get; set; }

            public int Size { get; set; }
            public int StockQuantity { get; set; }
        }
    }
}

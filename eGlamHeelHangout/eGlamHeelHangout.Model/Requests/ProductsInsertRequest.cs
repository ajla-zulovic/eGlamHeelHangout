using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
  public class ProductsInsertRequest
  {
    [Required(AllowEmptyStrings =false, ErrorMessage = "Producst Name is required !")]

    public string Name { get; set; }
    [Required(AllowEmptyStrings = false,ErrorMessage ="Description Name is required !")]
    public string Description { get; set; }
    [Required(ErrorMessage ="Price is required !")]
    [Range(1,10000)]
    public decimal Price { get; set; }
    [Required(ErrorMessage = "ImageUrl is required !")]
    public string ImageUrl { get; set; }
    [Required(ErrorMessage = "Category is required !")]
    public int CategoryID { get; set; }
    [Required(AllowEmptyStrings = false,ErrorMessage ="Material is required !")]
    public string Material { get; set; }
    [Required(AllowEmptyStrings = false,ErrorMessage ="Color is required !")]
    public string Color { get; set; }
   
    public decimal? HeelHeight { get; set; } // ne mora svaka obuca imati petu 
  }
}

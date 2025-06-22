using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
  public interface IProductService : ICRUDService<Model.Products, Model.SearchObjects.ProductsSearchObjects, Model.Requests.ProductsInsertRequest, Model.Requests.ProductsUpdateRequest>
  {
    Task<Model.Products> Activate(int id);
    Task<Model.Products> Hide(int id);
    Task<List<string>> AllowedActions(int id);
    Task<List<Model.ProductSizes>> GetSizesForProductAsync(int productId);
   List<Model.Products> Recommend(int currentUserId);


    }
}

using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography.X509Certificates;

namespace eGlamHeelHangout.Controllers
{
  [ApiController]
  [Route("[controller]")] // ovo nam ne treba 
  public class ProductController : BaseCRUDController<Model.Products,Model.SearchObjects.ProductsSearchObjects,Model.Requests.ProductsInsertRequest,Model.Requests.ProductsUpdateRequest>
  {
    public ProductController(ILogger<BaseController<Model.Products, Model.SearchObjects.ProductsSearchObjects>> logger, IProductService service)
      : base(logger, service)
    { }

      [HttpPut("{id}/activate")]
      public virtual async Task<Model.Products> Activate(int id)
    {
      return await (_service as IProductService).Activate(id);
    }

    [HttpPut("{id}/hide")]
    public virtual async Task<Model.Products> Hide(int id)
    {
      return await (_service as IProductService).Hide(id);
    }

    [HttpGet("{id}/AllowedActions")]
   public virtual async Task<List<string>> AllowedActions(int id)
    {
      return await (_service as IProductService).AllowedActions(id);
    }

  }
}

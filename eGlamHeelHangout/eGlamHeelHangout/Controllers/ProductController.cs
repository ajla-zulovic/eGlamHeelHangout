using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography.X509Certificates;

namespace eGlamHeelHangout.Controllers
{
  [ApiController]
  [Route("[controller]")] // ovo nam ne treba 
  public class ProductController : BaseCRUDController<Model.Products,Model.SearchObjects.ProductsSearchObjects,Model.Requests.ProductsInsertRequest,Model.Requests.ProductsUpdateRequest>
  {
        private readonly IReviewService _reviewService;
        private readonly IProductService _productService;
        public ProductController(ILogger<BaseController<Model.Products, Model.SearchObjects.ProductsSearchObjects>> logger, IProductService service, IReviewService reviewService)
      : base(logger, service)
    {
            _reviewService = reviewService;
            _productService = service;
        }

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
       
        [HttpGet("{productId}/sizes")]
        public async Task<IActionResult> GetSizes(int productId)
        {
            var sizes = await (_service as IProductService).GetSizesForProductAsync(productId);
            return Ok(sizes);
        }

        [HttpGet("{productId}/average-rating")]
        public async Task<IActionResult> GetAverageRating(int productId)
        {
            var average = await _reviewService.GetAverageRatingAsync(productId);
            return Ok(average);
        }


        [HttpGet("{userId}/recommend")]
        public ActionResult<List<eGlamHeelHangout.Model.Products>> Recommend(int userId)
        {
            var result = _productService.Recommend(userId);
            return Ok(result);
        }


    }
}

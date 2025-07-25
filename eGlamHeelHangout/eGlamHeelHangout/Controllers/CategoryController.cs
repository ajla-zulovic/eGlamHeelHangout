using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eGlamHeelHangout.Controllers
{
 
    [ApiController]
    [Route("[controller]")]
    [AllowAnonymous]
    public class CategoryController : BaseCRUDController<Categories, CategorySearchObject, CategoryInsertRequest, CategoryUpdateRequest>
    {
        private readonly ICategoryService _categoryService;
        public CategoryController(ILogger<BaseController<Categories, Model.SearchObjects.CategorySearchObject>> logger, ICategoryService service) : base(logger, service)
        {
            _categoryService = service;
        }

        [HttpPut("{id}/active")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Activate(int id)
        {
            var result = await _categoryService.Activate(id);
            if (!result)
                return NotFound();

            return Ok();
        }


        [HttpPut("{id}/deactivate")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Deactivate(int id)
        {
            var result = await _categoryService.Deactivate(id);
            if (!result)
                return NotFound();

            return Ok();
        }
    }
}

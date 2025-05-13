using eGlamHeelHangout.Model;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eGlamHeelHangout.Controllers
{
 
    [ApiController]
    [Route("[controller]")]
    [AllowAnonymous]
    public class CategoryController : BaseController<Model.Categories, Model.SearchObjects.CategorySearchObject>
    {
        public CategoryController(ILogger<BaseController<Categories, Model.SearchObjects.CategorySearchObject>> logger, ICategoryService service) : base(logger, service)
        {
        }
    }
}

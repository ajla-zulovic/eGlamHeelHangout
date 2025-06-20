using eGlamHeelHangout.Model;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eGlamHeelHangout.Controllers
{
  //[ApiController] //ovo nam ne treba u generickim kontrolerima
  [Route("[controller]")]
  [Authorize] //ovo ce omoguciti da svaki endpoint zahtjeva autorizaciju jer smo stavili u baznom controlleru kojeg nasljeđuje svaki nas custom controller :)
  public class BaseController<T,TSearch> : ControllerBase where T:class where TSearch:class
  {
    protected readonly ILogger<BaseController<T, TSearch>> _logger; // bolje protected zbog nasljeđivanja
    protected readonly IService<T, TSearch> _service;
    public BaseController(ILogger<BaseController<T, TSearch>> logger, IService<T, TSearch> service)
    {
      _logger = logger;
      _service = service;

    }
    [HttpGet]
    //[AllowAnonymous]
    public async Task<PagedResult<T>> Get([FromQuery]TSearch ? search=null)
    {
      return await _service.Get(search);
    }

    [HttpGet("{id}")]
    public async Task<T> GetById(int id)
    {
      return await _service.GetById(id);
    }
      
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public virtual async Task<IActionResult> Delete(int id)
        {
            var success = await _service.Delete(id);
            if (success)
                return Ok(new { message = $"{typeof(T).Name} deleted successfully." });

            return BadRequest("Something went wrong while deleting.");
        }


    }
}

// where T : class -> gdje genericki parametar mora biti klasa :)

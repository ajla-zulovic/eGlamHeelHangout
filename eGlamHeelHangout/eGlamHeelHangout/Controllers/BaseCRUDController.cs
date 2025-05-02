using eGlamHeelHangout.Model;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eGlamHeelHangout.Controllers
{
  //[ApiController] //ovo nam ne treba u generickim kontrolerima
  [Route("[controller]")]
  public class BaseCRUDController<T, TSearch, TInsert, TUpdate> : BaseController<T, TSearch> where T : class where TSearch : class
  {
    protected readonly ILogger<BaseController<T, TSearch>> _logger; // bolje protected zbog nasljeđivanja
    protected readonly ICRUDService<T, TSearch,TInsert,TUpdate> _service;
    public BaseCRUDController(ILogger<BaseController<T, TSearch>> logger, ICRUDService<T, TSearch, TInsert, TUpdate> service)
      : base(logger, service)
    {
      _logger = logger;
      _service = service;

    }

    [HttpPost]
    [Authorize(Roles= "Admin")] 
    public virtual async Task<T> Insert([FromBody]TInsert insert)
    {
      return await _service.Insert(insert);
    }

    [HttpPut("{id}")]
    public virtual async Task<T> Update(int id, TUpdate update)
    {
      return await _service.Update(id, update);
    }
    
  }
}

// where T : class -> gdje genericki parametar mora biti klasa :)

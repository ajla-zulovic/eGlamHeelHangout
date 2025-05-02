using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eGlamHeelHangout.Controllers
{
  [ApiController]
  [Route("[controller]")]
  public class UserController : BaseCRUDController<Model.Users,Model.SearchObjects.UserSearchObjects,Model.Requests.UsersInsertRequest, Model.Requests.UserUpdateRequest>
  {
    public UserController(ILogger<BaseController<Model.Users, Model.SearchObjects.UserSearchObjects>> logger, IUserService service)
      : base(logger, service)
    {
    
    }

    //[Authorize(Roles="Admin")]  //sad ne znam koliko ovo ima smisla za moju app ://
    //public override Task<Users> Insert([FromBody] UsersInsertRequest insert)
    //{
    //  return base.Insert(insert);
    //}



  }
}

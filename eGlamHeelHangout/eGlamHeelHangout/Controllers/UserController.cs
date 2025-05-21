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
        private readonly IUserService _userService;
        public UserController(ILogger<BaseController<Model.Users, Model.SearchObjects.UserSearchObjects>> logger, IUserService service)
      : base(logger, service)
    {
            _userService = service;
    }


        [Authorize]
        [HttpGet("current")]
        public async Task<ActionResult<Model.Users>> GetCurrentUser()
        {
            Console.WriteLine("Pozvan je GetCurrentUser");

            var username = HttpContext.User.Identity?.Name;
            Console.WriteLine($" Username iz konteksta: {username}");

            if (string.IsNullOrEmpty(username))
                return Unauthorized();

            var user = await _userService.GetCurrentUser(username); 

            if (user == null)
                return NotFound();

            return Ok(user);
        }
    }


    //[Authorize(Roles="Admin")]  //sad ne znam koliko ovo ima smisla za moju app ://
    //public override Task<Users> Insert([FromBody] UsersInsertRequest insert)
    //{
    //  return base.Insert(insert);
    //}



}


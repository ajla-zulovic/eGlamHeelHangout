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
        //overridam metodu jer mi treba pristup svima : 
        [HttpPost("register")]
        [AllowAnonymous]
        public override async Task<eGlamHeelHangout.Model.Users> Insert([FromBody] Model.Requests.UsersInsertRequest insert)
        {
            return await _userService.Insert(insert);
        }

        [HttpPut("change-password")]
        [Authorize]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            var username = HttpContext.User.Identity?.Name;
            if (string.IsNullOrWhiteSpace(username))
                return Unauthorized();

            request.Username = username;

            try
            {
                await (_userService as IUserService).ChangePassword(request);
                return Ok(new { message = "Password changed successfully." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{id}/promote")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> PromoteToAdmin(int id)
        {
            var result = await _userService.PromoteToAdmin(id);
            return Ok(result);
        }

        [HttpPut("{id}/demote")]
        public async Task<IActionResult> DemoteFromAdmin(int id)
        {
            var currentUserId = _userService.GetCurrentUserId(User.Identity.Name);
            try
            {
                var result = await _userService.DemoteFromAdmin(id, currentUserId);
                if (!result)
                    return NotFound();
                return Ok();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public override async Task<IActionResult> Delete(int id)
        {
            var currentUserId = _userService.GetCurrentUserId(User.Identity.Name);
            try
            {
                var result = await _userService.Delete(id, currentUserId);
                if (!result)
                    return NotFound();
                return NoContent();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }



    }
}


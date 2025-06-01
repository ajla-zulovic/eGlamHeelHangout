using eGlamHeelHangout.Model;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eGlamHeelHangout.Controllers
{

    [ApiController]
    [Route("[controller]")]
    public class FavoriteController : ControllerBase
    {
        private readonly IFavoriteService _favoriteService;
        private readonly IUserService _userService;

        public FavoriteController(IFavoriteService favoriteService, IUserService userService)
        {
            _favoriteService = favoriteService;
            _userService = userService;
        }

     
        [HttpPost("toggle")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> ToggleFavorite([FromBody] FavoriteToggleRequest request)
        {
            var username = HttpContext.User.Identity?.Name;
            if (string.IsNullOrEmpty(username))
                return Unauthorized();

            var userId = _userService.GetCurrentUserId(username);
            var liked = await _favoriteService.ToggleFavorite(userId, request.ProductId);

            return Ok(new { liked });
        }

        
        [HttpGet]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> GetMyFavorites()
        {
            var username = HttpContext.User.Identity?.Name;
            if (string.IsNullOrEmpty(username))
                return Unauthorized();

            var userId = _userService.GetCurrentUserId(username);
            var favorites = await _favoriteService.GetFavorites(userId);

            return Ok(favorites);
        }
    }
}

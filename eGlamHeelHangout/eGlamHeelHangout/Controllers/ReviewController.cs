using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Service;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace eGlamHeelHangout.Controllers
{
 
    [ApiController]
    [Route("[controller]")]

    public class ReviewController : ControllerBase
    {
        private readonly IReviewService _reviewService;

        public ReviewController(IReviewService reviewService)
        {
            _reviewService = reviewService;
        }

        [HttpPost]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> AddOrUpdateReview([FromBody] ReviewInsertRequest request)
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdString, out int userId))
                return Unauthorized("User not authenticated.");

            await _reviewService.AddOrUpdateReviewAsync(userId, request);
            return Ok("Review saved successfully.");
        }

        [HttpGet("product/{productId}")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> GetReviewsForProduct(int productId)
        {
            var reviews = await _reviewService.GetReviewsForProductAsync(productId);
            return Ok(reviews);
        }
        [HttpGet("average/{productId}")]
        [Authorize]
        public async Task<IActionResult> GetAverageRating(int productId)
        {
            var average = await _reviewService.GetAverageRatingAsync(productId);
            return Ok(average);
        }

    }
}

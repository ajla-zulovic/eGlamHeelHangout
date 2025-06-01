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
        public async Task<IActionResult> AddReview([FromBody] ReviewInsertRequest request)
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdString, out int userId))
                return Unauthorized("User not authenticated.");

            var alreadyReviewed = await _reviewService.HasUserAlreadyReviewed(userId, request.ProductId);
            if (alreadyReviewed)
                return BadRequest("You have already reviewed this product.");

            await _reviewService.AddReviewAsync(userId, request);
            return Ok("Review submitted successfully.");
        }
        [HttpGet("product/{productId}")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> GetReviewsForProduct(int productId)
        {
            var reviews = await _reviewService.GetReviewsForProductAsync(productId);
            return Ok(reviews);
        }

    }
}

using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Service.Database;
using Microsoft.EntityFrameworkCore;


namespace eGlamHeelHangout.Service
{
    public class ReviewService:IReviewService
    {

        private readonly _200199Context _context;

        public ReviewService(_200199Context context)
        {
            _context = context;
        }

        public async Task<double> GetAverageRatingAsync(int productId)
        {
            var avg = await _context.Reviews
                .Where(r => r.ProductId == productId)
                .AverageAsync(r => (double?)r.Rating) ?? 0;

            return Math.Round(avg, 1);
        }

        public async Task<bool> HasUserAlreadyReviewed(int userId, int productId)
        {
            return await _context.Reviews.AnyAsync(r => r.UserId == userId && r.ProductId == productId);
        }

        public async Task AddOrUpdateReviewAsync(int userId, ReviewInsertRequest request)
        {
            var existingReview = await _context.Reviews
                .FirstOrDefaultAsync(r => r.UserId == userId && r.ProductId == request.ProductId);

            if (existingReview != null)
            {
                existingReview.Rating = request.Rating;
                existingReview.ReviewDate = DateTime.UtcNow;
                _context.Reviews.Update(existingReview);
            }
            else
            {
                var review = new Review
                {
                    ProductId = request.ProductId,
                    UserId = userId,
                    Rating = request.Rating,
                    ReviewDate = DateTime.UtcNow
                };
                _context.Reviews.Add(review);
            }

            await _context.SaveChangesAsync();
        }

        public async Task<List<Model.ReviewDTO>> GetReviewsForProductAsync(int productId)
        {
            return await _context.Reviews
                .Where(r => r.ProductId == productId)
                .Select(r => new ReviewDTO
                {
                    ReviewId = r.ReviewId,
                    Rating = r.Rating,
                    Comment = r.Comment,
                    ReviewDate = r.ReviewDate,
                    Username = r.User.Username
                }).ToListAsync();
        }

    }
}

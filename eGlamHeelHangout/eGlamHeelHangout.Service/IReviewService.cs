using eGlamHeelHangout.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{

    public interface IReviewService 
    {
        Task<double> GetAverageRatingAsync(int productId);
        Task AddReviewAsync(int userId, ReviewInsertRequest request);
        Task<bool> HasUserAlreadyReviewed(int userId, int productId);
        Task<List<Model.ReviewDTO>> GetReviewsForProductAsync(int productId);

    }
}

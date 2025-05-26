using eGlamHeelHangout.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
    public interface IFavoriteService
    {
        public Task<bool> ToggleFavorite(int userId, int productId);
        Task<List<Product>> GetFavorites(int userId);
    }
}

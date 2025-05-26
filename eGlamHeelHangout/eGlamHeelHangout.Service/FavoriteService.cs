using AutoMapper;
using eGlamHeelHangout.Service.Database;
using eGlamHeelHangout.Service.ProductStateMachine;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
    public class FavoriteService:IFavoriteService
    {
        _200199Context _context;
        public IMapper _mapper { get; set; }
        public FavoriteService(_200199Context context, IMapper mapper, BaseState baseState)
        {
            _context = context;
            _mapper = mapper;
        }
        public async Task<bool> ToggleFavorite(int userId, int productId)
        {
            var existing = await _context.Favorites
                .FirstOrDefaultAsync(f => f.UserId == userId && f.ProductId == productId);

            if (existing != null)
            {
                _context.Favorites.Remove(existing);
                await _context.SaveChangesAsync();
                return false; // unliked
            }

            var favorite = new Favorite
            {
                UserId = userId,
                ProductId = productId,
                DateAdded = DateTime.Now
            };

            _context.Favorites.Add(favorite);
            await _context.SaveChangesAsync();
            return true; // liked
        }

        //dohvati sve favorite proizvode: 
        public async Task<List<Product>> GetFavorites(int userId)
        {
            var favorites = await _context.Favorites
                .Include(f => f.Product)
                .Where(f => f.UserId == userId)
                .Select(f => f.Product)
                .ToListAsync();

            return favorites;
        }


    }
}

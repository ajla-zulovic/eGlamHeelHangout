using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class FavoriteSeed
    {
        public static void Seed(_200199Context context)
        {
            var existing = context.Favorites
            .Where(f => f.UserId == 2 && (f.ProductId == 1 || f.ProductId == 2))
            .Select(f => f.ProductId)
            .ToHashSet();

            var toInsert = new List<Favorite>();

            if (!existing.Contains(1))
            {
                toInsert.Add(new Favorite
                {
                    UserId = 2,
                    ProductId = 1,
                    DateAdded = new DateTime(2025, 7, 3)
                });
            }

            if (!existing.Contains(2))
            {
                toInsert.Add(new Favorite
                {
                    UserId = 2,
                    ProductId = 2,
                    DateAdded = DateTime.UtcNow
                });
            }

            if (toInsert.Count == 0)
            {
                Console.WriteLine(">> Nothing to seed for Favorites.");
                return;
            }

            using var tx = context.Database.BeginTransaction();
            context.Favorites.AddRange(toInsert);
            context.SaveChanges();
            tx.Commit();

            Console.WriteLine($">> Inserted {toInsert.Count} favorite(s).");
        }
    }
}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class FavoriteSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.Favorites.Any())
                return;

            Console.WriteLine(">> Seeding favorites...");

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Favorites ON");

            context.Favorites.Add(
                new Favorite
                {
                    FavoriteId = 1,
                    UserId = 2,
                    ProductId = 1,
                    DateAdded = new DateTime(2025, 7, 3)
                }
            );

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Favorites OFF");

            transaction.Commit();

            Console.WriteLine(">> Favorite seed completed.");
        }
    }
}

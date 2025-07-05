using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class ReviewSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.Reviews.Any())
                return;

            Console.WriteLine(">> Seeding reviews...");

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Reviews ON");

            context.Reviews.AddRange(
                new Review
                {
                    ReviewId = 1,
                    UserId = 2,
                    ProductId = 1,
                    Rating = 5,
                    ReviewDate = new DateTime(2023, 1, 5)
                },
                new Review
                {
                    ReviewId = 2,
                    UserId = 2,
                    ProductId = 2,
                    Rating = 4,
                    ReviewDate = new DateTime(2023, 1, 10)
                }
            );

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Reviews OFF");

            transaction.Commit();

            Console.WriteLine(">> Review seed completed.");
        }
    }
}

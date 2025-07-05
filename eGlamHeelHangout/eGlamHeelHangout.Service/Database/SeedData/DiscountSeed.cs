using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class DiscountSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.Discounts.Any())
                return;

            Console.WriteLine(">> Seeding discounts...");

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Discounts ON");

            context.Discounts.Add(
                new Discount
                {
                    DiscountId = 1,
                    ProductId = 1,
                    DiscountPercentage = 20,
                    StartDate = new DateTime(2025, 7, 3),
                    EndDate = new DateTime(2025, 8, 19)
                }
            );

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Discounts OFF");

            transaction.Commit();

            Console.WriteLine(">> Discount seed completed.");
        }
    }
}

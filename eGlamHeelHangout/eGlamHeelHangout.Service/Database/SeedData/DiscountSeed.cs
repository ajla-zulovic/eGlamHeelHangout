using Microsoft.EntityFrameworkCore;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class DiscountSeed
    {
        public static void Seed(_200199Context context)
        {
            Console.WriteLine(">> Seeding discounts...");

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Discounts ON");
            if (!context.Discounts.Any(d => d.ProductId == 1))
            {
                context.Discounts.Add(
                    new Discount
                    {
                        DiscountId = 1,
                        ProductId = 1,
                        DiscountPercentage = 20,
                        StartDate = new DateTime(2025, 7, 3),
                        EndDate = new DateTime(2025, 10, 19)
                    }
                );
            }

            
            if (!context.Discounts.Any(d => d.ProductId == 4))
            {
                context.Discounts.Add(
                    new Discount
                    {
                        DiscountId = 2,
                        ProductId = 4,
                        DiscountPercentage = 15,
                        StartDate = new DateTime(2025, 8, 20),
                        EndDate = new DateTime(2025, 9, 10)
                    }
                );
            }

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Discounts OFF");

            transaction.Commit();

            Console.WriteLine(">> Discount seed completed.");
        }
    }
}

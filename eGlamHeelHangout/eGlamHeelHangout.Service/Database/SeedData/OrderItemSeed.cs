using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class OrderItemSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.OrderItems.Any())
                return;

            Console.WriteLine(">> Seeding order items...");

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT OrderItems ON");

            context.OrderItems.Add(
                new OrderItem
                {
                    OrderItemId = 1,
                    OrderId = 1,
                    ProductId = 1,
                    Quantity = 1,
                    PricePerUnit = 80,
                    ProductSizeId = 1
                }
            );

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT OrderItems OFF");

            transaction.Commit();

            Console.WriteLine(">> OrderItem seed completed.");
        }
    }
}

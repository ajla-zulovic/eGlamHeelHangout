using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class OrderSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.Orders.Any())
                return;

            Console.WriteLine(">> Seeding orders...");

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Orders ON");


            var orders = new List<Order>
{
                new Order
                {
                    OrderId = 1,
                    UserId = 2,
                    OrderStatus = "Pending",
                    TotalPrice = 99.99m,
                    PaymentMethod = "Card",
                    OrderDate = new DateTime(2025, 5, 29),
                    FullName = "UserF UserL",
                    Email = "user@example.com",
                    Address = "Main Street 12",
                    City = "Sarajevo",
                    PostalCode = "71000",
                    PhoneNumber = "+38761234567"
                },
                new Order
                {
                    OrderId = 2,
                    UserId = 2,
                    OrderStatus = "Delivered",
                    TotalPrice = 79.50m,
                    PaymentMethod = "Card",
                    OrderDate = new DateTime(2025, 6, 15),
                    FullName = "UserF UserL",
                    Email = "user@example.com",
                    Address = "Main Street 12",
                    City = "Sarajevo",
                    PostalCode = "71000",
                    PhoneNumber = "+38761234567"
                },
                 new Order
                {
                    OrderId = 3,
                    UserId = 2,
                    OrderStatus = "Canceled",
                    TotalPrice = 105.00m,
                    PaymentMethod = "Card",
                    OrderDate = new DateTime(2025, 4, 23),
                    FullName = "UserF UserL",
                    Email = "user@example.com",
                    Address = "Main Street 12",
                    City = "Sarajevo",
                    PostalCode = "71000",
                    PhoneNumber = "+38761234567"
                }
            };

            context.Orders.AddRange(orders);
            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Orders OFF");

            transaction.Commit();

            Console.WriteLine(">> Order seed completed.");
        }
    }
}

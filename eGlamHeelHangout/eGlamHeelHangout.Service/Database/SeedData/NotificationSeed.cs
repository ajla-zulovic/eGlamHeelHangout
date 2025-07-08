using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.EntityFrameworkCore;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class NotificationSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.Notifications.Any())
                return;

            Console.WriteLine(">> Seeding notifications...");

            var notifications = new List<Notification>
            {
                new Notification
                {
                    NotificationId = 1,
                    UserId = 2, 
                    Message = "Check out our new product: Black Jackie J Heels!",
                    NotificationType = "NewProduct",
                    DateSent = new DateTime(2025, 7, 5, 10, 30, 0),
                    IsRead = false,
                    ProductId = 1 
                }
            };

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Notifications ON");
            context.Notifications.AddRange(notifications);
            context.SaveChanges();
            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Notifications OFF");

            transaction.Commit();

            Console.WriteLine(">> Notification seed completed.");
        }
    }
}

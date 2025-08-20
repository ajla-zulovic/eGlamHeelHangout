using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class NotificationSeed
    {
        public static void Seed(_200199Context context)
        {
            Console.WriteLine(">> Seeding notifications...");

            var notifications = new List<Notification>();

            if (!context.Notifications.Any(n => n.NotificationId == 1))
            {
                notifications.Add(new Notification
                {
                    NotificationId = 1,
                    UserId = 2,
                    Message = "Check out our new product: Black Jackie J Heels!",
                    NotificationType = "NewProduct",
                    DateSent = new DateTime(2025, 7, 5, 10, 30, 0),
                    IsRead = false,
                    ProductId = 1
                });
            }

            if (!context.Notifications.Any(n => n.NotificationId == 2))
            {
                notifications.Add(new Notification
                {
                    NotificationId = 2,
                    UserId = 2,
                    Message = "Win special offer!",
                    NotificationType = "NewGiveaway",
                    DateSent = new DateTime(2025, 8, 20, 14, 00, 0),
                    IsRead = false,
                    GiveawayId = 1
                });
            }

            if (notifications.Count == 0)
            {
                Console.WriteLine(">> Notifications already seeded.");
                return;
            }

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

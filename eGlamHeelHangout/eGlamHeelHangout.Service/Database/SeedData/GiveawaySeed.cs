using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class GiveawaySeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.Giveaways.Any())
                return;

            Console.WriteLine(">> Seeding giveaways...");

            var assemblyPath = Path.GetDirectoryName(typeof(GiveawaySeed).Assembly.Location)!;
            Console.WriteLine("Assembly path: " + assemblyPath);

            var basePath = Path.Combine(AppContext.BaseDirectory, "SeedImages");
            basePath = Path.GetFullPath(basePath);
            Console.WriteLine("Base image path: " + basePath);

            if (Directory.Exists(basePath))
            {
                Console.WriteLine("Files found in SeedImages folder:");
                foreach (var file in Directory.GetFiles(basePath))
                {
                    Console.WriteLine(" - " + file);
                }
            }
            else
            {
                Console.WriteLine("[x] SeedImages folder does NOT exist at: " + basePath);
            }

            var imagePath = Path.Combine(basePath, "giveaway1.png");
            Console.WriteLine("Trying to load image from: " + imagePath);

            byte[] imageBytes = File.Exists(imagePath)
                ? File.ReadAllBytes(imagePath)
                : new byte[0];

            if (imageBytes.Length == 0)
                Console.WriteLine(" Image NOT FOUND or empty.");
            else
                Console.WriteLine($"Image found and loaded. Bytes: {imageBytes.Length}");

            var giveaways = new List<Giveaway>
            {
                new Giveaway
                {
                    GiveawayId = 1,
                    Title = "Win Red Heels!",
                    Description = "Elegant heels for special occasion!",
                    Color = "Brown",
                    HeelHeight = 10,
                    GiveawayProductImage = imageBytes,
                    EndDate = new DateTime(2025, 7, 25),
                    IsClosed = false
                },
                new Giveaway
                {
                    GiveawayId = 2,
                    Title = "Win Black Heels!",
                    Description = "Another gorgeous pair!",
                    Color = "Black",
                    HeelHeight = 9,
                    GiveawayProductImage = imageBytes,
                    EndDate = new DateTime(2025, 6, 25),
                    IsClosed = true
                }
            };

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Giveaways ON");

            context.Giveaways.AddRange(giveaways);
            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Giveaways OFF");

            transaction.Commit();

            Console.WriteLine(">> Giveaway seed completed.");
        }

    }
}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class ProductSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.Products.Any())
                return;

            Console.WriteLine(">> Seeding products...");

            var basePath = Path.Combine(AppContext.BaseDirectory, "SeedImages");
            basePath = Path.GetFullPath(basePath);

            var products = new List<Product>
    {
        new Product
        {
            ProductId = 1,
            Name = "Black Jackie J Heels",
            CategoryId = 1,
            Color = "Black",
            Material = "Suede",
            HeelHeight = 10,
            Price = 99.99m,
            Description = "Perfect heels for a night out.",
            Image = LoadImage(basePath, "product1.png"),
            DateAdded = DateTime.UtcNow,
            StateMachine = "draft"
        },
        new Product
        {
            ProductId = 2,
            Name = "Summer Flats F",
            CategoryId = 2,
            Color = "Beige",
            Material = "Leather",
            HeelHeight = 1,
            Price = 79.50m,
            Description = "Light and comfy for summer walks.",
            Image = LoadImage(basePath, "product2.png"),
            DateAdded = DateTime.UtcNow,
            StateMachine = "draft"
        },
        new Product
        {
            ProductId = 3,
            Name = "Black Boots BB",
            CategoryId = 4,
            Color = "Black",
            Material = "Leather",
            HeelHeight = 8,
            Price = 120.00m,
            Description = "Stylish boots for all seasons.",
            Image = LoadImage(basePath, "product3.png"),
            DateAdded = DateTime.UtcNow,
            StateMachine = "draft"
        },
        new Product
        {
            ProductId = 4,
            Name = "Classic Pumps Slipers",
            CategoryId = 3,
            Color = "Nude",
            Material = "Leather",
            HeelHeight = 1,
            Price = 89.90m,
            Description = "Elegant and timeless style.",
            Image = LoadImage(basePath, "product4.png"),
            DateAdded = DateTime.UtcNow,
            StateMachine = "draft"
        },
        new Product
        {
            ProductId = 5,
            Name = "Brown L Loafers Stilettos",
            CategoryId = 5,
            Color = "Brown",
            Material = "Leather",
            HeelHeight = 11,
            Price = 105.00m,
            Description = "Shine on every occasion.",
            Image = LoadImage(basePath, "product5.png"),
            DateAdded = DateTime.UtcNow,
            StateMachine = "draft"
        }
    };

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Products ON");
            context.Products.AddRange(products);
            context.SaveChanges();
            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Products OFF");

            transaction.Commit();

            Console.WriteLine(">> Product seed completed.");
        }

        private static byte[] LoadImage(string basePath, string fileName)
        {
            var imagePath = Path.Combine(basePath, fileName);
            Console.WriteLine($"Loading image: {imagePath}");

            if (File.Exists(imagePath))
            {
                var bytes = File.ReadAllBytes(imagePath);
                Console.WriteLine($" Loaded {fileName} ({bytes.Length} bytes)");
                return bytes;
            }

            Console.WriteLine($" Image not found: {fileName}");
            return new byte[0];
        }

    }
}

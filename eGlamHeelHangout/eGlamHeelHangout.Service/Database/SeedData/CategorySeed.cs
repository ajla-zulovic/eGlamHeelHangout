using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class CategorySeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.Categories.Any())
                return;

            Console.WriteLine(">> Seeding categories...");

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Categories ON");

            context.Categories.AddRange(
                new Category { CategoryId = 1, CategoryName = "Heels" },
                new Category { CategoryId = 2, CategoryName = "Flats" },
                new Category { CategoryId = 3, CategoryName = "Slipers" },
                new Category { CategoryId = 4, CategoryName = "Boots" },
                new Category { CategoryId = 5, CategoryName = "Loafers" }
            );

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Categories OFF");

            transaction.Commit();

            Console.WriteLine(">> Category seed completed.");
        }
    }
}

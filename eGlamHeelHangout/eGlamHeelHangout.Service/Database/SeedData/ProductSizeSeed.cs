using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class ProductSizeSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.ProductSizes.Any())
                return;

            Console.WriteLine(">> Seeding product sizes...");

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT ProductSizes ON");

            context.ProductSizes.AddRange(
                new ProductSize { ProductSizeId = 1, ProductId = 1, Size = 36, StockQuantity = 5 },
                new ProductSize { ProductSizeId = 2, ProductId = 1, Size = 37, StockQuantity = 3 },
                new ProductSize { ProductSizeId = 3, ProductId = 1, Size = 38, StockQuantity = 6 },
                new ProductSize { ProductSizeId = 4, ProductId = 1, Size = 39, StockQuantity = 2 },
                new ProductSize { ProductSizeId = 5, ProductId = 1, Size = 40, StockQuantity = 4 },

                new ProductSize { ProductSizeId = 6, ProductId = 2, Size = 36, StockQuantity = 7 },
                new ProductSize { ProductSizeId = 7, ProductId = 2, Size = 37, StockQuantity = 4 },
                new ProductSize { ProductSizeId = 8, ProductId = 2, Size = 38, StockQuantity = 5 },
                new ProductSize { ProductSizeId = 9, ProductId = 2, Size = 39, StockQuantity = 6 },
                new ProductSize { ProductSizeId = 10, ProductId = 2, Size = 40, StockQuantity = 3 },

                new ProductSize { ProductSizeId = 11, ProductId = 3, Size = 36, StockQuantity = 4 },
                new ProductSize { ProductSizeId = 12, ProductId = 3, Size = 37, StockQuantity = 5 },

                new ProductSize { ProductSizeId = 13, ProductId = 4, Size = 38, StockQuantity = 3 },
                new ProductSize { ProductSizeId = 14, ProductId = 4, Size = 39, StockQuantity = 6 },

                new ProductSize { ProductSizeId = 15, ProductId = 5, Size = 40, StockQuantity = 10 }
            );

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT ProductSizes OFF");

            transaction.Commit();

            Console.WriteLine(">> ProductSize seed completed.");
        }
    }
}


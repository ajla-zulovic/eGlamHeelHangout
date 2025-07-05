using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class RoleSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.Roles.Any())
                return;

            Console.WriteLine(">> Seeding roles...");

            using var transaction = context.Database.BeginTransaction();  

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Roles ON");

            context.Roles.AddRange(
                new Role { RoleId = 1, RoleName = "Admin" },
                new Role { RoleId = 2, RoleName = "User" }
            );

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Roles OFF");

            transaction.Commit();  

            Console.WriteLine(">> Role seed completed.");
        }

    }
}

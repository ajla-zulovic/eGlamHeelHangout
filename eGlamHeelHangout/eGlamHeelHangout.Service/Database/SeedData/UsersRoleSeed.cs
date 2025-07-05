using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class UsersRoleSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.UsersRoles.Any())
                return;

            Console.WriteLine(">> Seeding users-roles...");

            context.UsersRoles.AddRange(
                new UsersRole
                {
                    UserId = 1,
                    RoleId = 1,
                    DateChange = new DateTime(2025, 1, 1)
                },
                new UsersRole
                {
                    UserId = 2,
                    RoleId = 2,
                    DateChange = new DateTime(2025, 1, 1)
                }
            );

            context.SaveChanges();
            Console.WriteLine(">> UsersRole seed completed.");
        }
    }
}

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class UserSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.Users.Any())
                return;

            Console.WriteLine(">> Seeding users...");

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Users ON");

            context.Users.AddRange(
                new User
                {
                    UserId = 1,
                    FirstName = "AdminF",
                    LastName = "AdminL",
                    Username = "admin",
                    Email = "admin@example.com",
                    PasswordHash = "vGQ/sj8GshpUEnnkwMCMx2kkzSlfgNdkTclda665gtOMTIQtaLflmlQ1GOn5FPXPE9cWPz3dOTTzPFvxKZVNmg==",
                    PasswordSalt = "2PZ2JOU0JX7QkF1OPO7rYBH2Ddb/BOi6VcMWMXaDh6St5ykp7reP4RHOD/0quN8hGCd6PiIIicHNwA6KqtcI+CIdB7odTOwhJUiPQGcSYFMGVsC1RPR0AHOR2RntJqBqWZnjzh1zVAmemxylN9V5KQma85AxxZKiU1juua3tDEc=",
                    PhoneNumber = "999888777",
                    Address = "Adminova adresa",
                    DateCreated = new DateTime(2023, 1, 1),
                    DateOfBirth = new DateTime(1990, 5, 10)
                },
                new User
                {
                    UserId = 2,
                    FirstName = "UserF",
                    LastName = "UserL",
                    Username = "user",
                    Email = "user@example.com",
                    PasswordHash = "g6gtqLWveYLDbPBuWd1hsac46R+rw7K3DTPvRXm2mxbDdnGB15mvTpWlMSpVbFoSEPqBcSx92fPqApU0eIpJaw==",
                    PasswordSalt = "FHo48OYqKD0k0JTVJ73JGGs+ahIzYlORJWKZ0154DTRSQ95MO1lgOxyBPcOI/DpVfdxLXPAe+mchNSTVBmyZZH/VXCNqbueNPaz41hXAIkFU6jB+VaBUbN6V3/h5gfAgShvxZwtPejIcgd0xuupHxNMhA1CGH+NQrFo2Yg6SyvY=",
                    PhoneNumber = "000111222",
                    Address = "Userova adresa",
                    DateCreated = new DateTime(2023, 1, 1),
                    DateOfBirth = new DateTime(2001, 5, 11)
                }
            );

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT Users OFF");

            transaction.Commit();

            Console.WriteLine(">> User seed completed.");
        }
    }
}

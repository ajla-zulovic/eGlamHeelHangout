using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class GiveawayParticipantSeed
    {
        public static void Seed(_200199Context context)
        {
            if (context.GiveawayParticipants.Any())
                return;

            Console.WriteLine(">> Seeding giveaway participants...");

            using var transaction = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT GiveawayParticipants ON");

            context.GiveawayParticipants.Add(
                new GiveawayParticipant
                {
                    ParticipantId = 1,
                    GiveawayId = 2,
                    UserId = 2,
                    Size = 38,
                    Address = "Grbavička 25",
                    PostalCode = "71000",
                    City = "Sarajevo",
                    IsWinner = true
                }
            );

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT GiveawayParticipants OFF");

            transaction.Commit();

            Console.WriteLine(">> Giveaway participant seed completed.");
        }
    }
}

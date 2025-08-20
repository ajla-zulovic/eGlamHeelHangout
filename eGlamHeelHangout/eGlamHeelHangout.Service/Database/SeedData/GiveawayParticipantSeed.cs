using Microsoft.EntityFrameworkCore;

namespace eGlamHeelHangout.Service.Database.SeedData
{
    public static class GiveawayParticipantSeed
    {
        public static void Seed(_200199Context context)
        {
            Console.WriteLine(">> Seeding giveaway participants...");

            bool hasP1 = context.GiveawayParticipants.Any(p => p.ParticipantId == 1);
            bool hasP2 = context.GiveawayParticipants.Any(p => p.ParticipantId == 2);

            using var tx = context.Database.BeginTransaction();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT GiveawayParticipants ON");

            if (!hasP1)
            {
                context.GiveawayParticipants.Add(new GiveawayParticipant
                {
                    ParticipantId = 1,
                    GiveawayId = 2,
                    UserId = 2,
                    Size = 38,
                    Address = "Grbavička 25",
                    PostalCode = "71000",
                    City = "Sarajevo",
                    IsWinner = true
                });
            }

            if (!hasP2)
            {
                context.GiveawayParticipants.Add(new GiveawayParticipant
                {
                    ParticipantId = 2,
                    GiveawayId = 3,
                    UserId = 2,
                    Size = 38,
                    Address = "Ulica 25",
                    PostalCode = "71000",
                    City = "Sarajevo",
                    IsWinner = false
                });
            }

            context.SaveChanges();

            context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT GiveawayParticipants OFF");

            tx.Commit();

            Console.WriteLine(">> Giveaway participant seed completed.");
        }
    }
}

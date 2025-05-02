using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service.Database
{
    public partial class Giveaway
    {
        public Giveaway()
        {
            GiveawayParticipants = new HashSet<GiveawayParticipant>();
        }

        public int GiveawayId { get; set; }
        public int ProductId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int? WinnerUserId { get; set; }

        public virtual Product Product { get; set; } = null!;
        public virtual User? WinnerUser { get; set; }
        public virtual ICollection<GiveawayParticipant> GiveawayParticipants { get; set; }
    }
}

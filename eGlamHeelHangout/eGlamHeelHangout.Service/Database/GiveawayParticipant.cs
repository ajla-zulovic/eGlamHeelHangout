using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service.Database
{
    public partial class GiveawayParticipant
    {
        public int ParticipantId { get; set; }
        public int GiveawayId { get; set; }
        public int UserId { get; set; }
        public string Size { get; set; } = null!;
        public DateTime? DateJoined { get; set; }

        public virtual Giveaway Giveaway { get; set; } = null!;
        public virtual User User { get; set; } = null!;
    }
}

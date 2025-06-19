using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service.Database
{
    public partial class Giveaway
    {
        public int GiveawayId { get; set; }

        public DateTime EndDate { get; set; }
        public string Color { get; set; }
        public string Description { get; set; }
        public decimal HeelHeight { get; set; }
        public bool IsClosed { get; set; } = false;
        public string Title { get; set; }
        public byte[] GiveawayProductImage { get; set; }
        public virtual ICollection<GiveawayParticipant> GiveawayParticipants { get; set; } = new List<GiveawayParticipant>();
    }
}

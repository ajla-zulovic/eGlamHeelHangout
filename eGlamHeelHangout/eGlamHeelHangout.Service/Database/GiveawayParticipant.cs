using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service.Database
{
    public partial class GiveawayParticipant
    {
        public int ParticipantId { get; set; }
        public int GiveawayId { get; set; }
        public int UserId { get; set; }
        public int Size { get; set; }
      
        public virtual Giveaway Giveaway { get; set; } = null!;
        public virtual User User { get; set; } = null!;

        public string Address { get; set; }
        public string PostalCode { get; set; }
        public string City { get; set; }
        public bool IsWinner { get; set; }
   
    }
}

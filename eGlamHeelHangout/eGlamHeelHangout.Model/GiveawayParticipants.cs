using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
    public class GiveawayParticipants
    {
        public int ParticipantId { get; set; }
        public int GiveawayId { get; set; }
        public int UserId { get; set; }
        public int Size { get; set; }
        public bool IsWinner { get; set; }
    }
}

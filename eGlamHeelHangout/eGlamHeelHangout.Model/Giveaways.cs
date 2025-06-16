using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
    public class Giveaways
    {

        public int GiveawayId { get; set; }
        public string Title { get; set; }
        public string Color { get; set; }
        public string HeelHeight { get; set; }
        public string Description { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsClosed { get; set; }

        public byte[] GiveawayProductImage { get; set; }
        public string? WinnerName { get; set; }
    }

}

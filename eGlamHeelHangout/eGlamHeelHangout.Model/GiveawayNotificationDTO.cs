using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
    public class GiveawayNotificationDTO
    {

        public int GiveawayId { get; set; }
        public string Title { get; set; }
        public string Color { get; set; }
        public decimal HeelHeight { get; set; }
        public string Description { get; set; }
        public string GiveawayProductImage { get; set; }
    }
}

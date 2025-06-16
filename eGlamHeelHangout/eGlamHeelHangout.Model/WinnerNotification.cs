using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
    public class WinnerNotification
    {
        public int GiveawayId { get; set; }
        public string GiveawayTitle { get; set; }
        public int WinnerUserId { get; set; }
        public string WinnerUsername { get; set; }
        public DateTime NotificationDate { get; set; }
    }
}

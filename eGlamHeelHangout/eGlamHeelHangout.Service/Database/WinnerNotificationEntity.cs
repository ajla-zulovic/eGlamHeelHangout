using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service.Database
{
    public class WinnerNotificationEntity
    {
        public int Id { get; set; }
        public string GiveawayTitle { get; set; }
        public string WinnerUsername { get; set; }
        public int GiveawayId { get; set; }
        public DateTime NotificationDate { get; set; }
        [ForeignKey(nameof(GiveawayId))]

        public virtual Giveaway Giveaway { get; set; }
        public int WinnerUserId { get; set; }
        [ForeignKey(nameof(WinnerUserId))]
        public virtual User User { get; set; }

    }
}

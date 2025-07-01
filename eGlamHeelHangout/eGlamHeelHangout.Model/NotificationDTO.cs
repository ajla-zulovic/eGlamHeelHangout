using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
    public class NotificationDTO
    {
        public int NotificationId { get; set; }
        public string Message { get; set; } = null!;
        public string NotificationType { get; set; } = null!;
        public DateTime? DateSent { get; set; }
        public bool? IsRead { get; set; }

        public int? ProductId { get; set; }
        public string? ProductName { get; set; }

        public int? GiveawayId { get; set; }
        public string? GiveawayTitle { get; set; }
    }
}

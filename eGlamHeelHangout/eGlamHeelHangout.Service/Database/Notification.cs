using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service.Database
{
    public partial class Notification
    {
        public int NotificationId { get; set; }

        public int UserId { get; set; }                      
        public string Message { get; set; } = null!;        
        public string NotificationType { get; set; } = null!; 

        public DateTime? DateSent { get; set; }            
        public bool? IsRead { get; set; }                   

        public int? ProductId { get; set; }
        public Product? Product { get; set; }

        public int? GiveawayId { get; set; }
        public Giveaway? Giveaway { get; set; }

        public virtual User User { get; set; } = null!;
    }
}

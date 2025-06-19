using System;
using System.Collections.Generic;

namespace eGlamHeelHangout.Service.Database
{
    public partial class User
    {
        public User()
        {

            Favorites = new HashSet<Favorite>();
            UsersRoles = new HashSet<UsersRole>();
            GiveawayParticipants = new HashSet<GiveawayParticipant>();
            Notifications = new HashSet<Notification>();
            Orders = new HashSet<Order>();
            Reviews = new HashSet<Review>();
        }

        public int UserId { get; set; }
        public string FirstName { get; set; } = null!;
        public string LastName { get; set; } = null!;
        public string Username { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string PasswordHash { get; set; } = null!;
        public string PasswordSalt { get; set; } = null!;
        public string PhoneNumber { get; set; }
        public string? Address { get; set; }
        public DateTime? DateCreated { get; set; }
        public byte[]? ProfileImage { get; set; }
        public DateTime? DateOfBirth { get; set; }



        public virtual ICollection<UsersRole> UsersRoles { get; } = new List<UsersRole>();
    public virtual ICollection<Favorite> Favorites { get; set; }
        public virtual ICollection<GiveawayParticipant> GiveawayParticipants { get; set; }
     
        public virtual ICollection<Notification> Notifications { get; set; }
        public virtual ICollection<Order> Orders { get; set; }
        public virtual ICollection<Review> Reviews { get; set; }
    }
}

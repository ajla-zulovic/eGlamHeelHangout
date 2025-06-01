using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model
{
    public class ReviewDTO
    {
        public int ReviewId { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime? ReviewDate { get; set; }
        public string? Username { get; set; } // npr. za prikaz korisničkog imena
    }
}

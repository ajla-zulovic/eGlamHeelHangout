using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
    public class GiveawayInsertRequest
    {
        public string Title { get; set; }
        public string Color { get; set; }
        [Required]
        [Range(1, 50)]
        public decimal HeelHeight { get; set; }
        public string Description { get; set; }
        public DateTime EndDate { get; set; }
        public string GiveawayProductImage { get; set; }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
    public class GiveawayInsertRequest
    {
        public string Title { get; set; }
        public string Color { get; set; }
        public string HeelHeight { get; set; }
        public string Description { get; set; }
        public DateTime EndDate { get; set; }

        public byte[] GiveawayProductImage { get; set; }
    }
}

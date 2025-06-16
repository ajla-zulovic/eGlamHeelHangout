using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
    public class GiveawayParticipantInsertRequest
    {
        public int GiveawayId { get; set; }
        public int Size { get; set; }
        public string Address { get; set; } //polja za "isporuku" narudzbe
        public string PostalCode { get; set; }
        public string City { get; set; }
        
        
    }
}

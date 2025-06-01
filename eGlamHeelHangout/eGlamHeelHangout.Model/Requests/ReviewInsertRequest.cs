using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.Requests
{
    public class ReviewInsertRequest
    {
        public int ProductId { get; set; }
        public int Rating { get; set; }
    }
}

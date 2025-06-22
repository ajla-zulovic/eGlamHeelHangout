using Microsoft.ML.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service.Recommender
{
    public class ProductEntry
    {
        [KeyType(100)]
        public uint UserId { get; set; }

        [KeyType(100)]
        public uint ProductId { get; set; }


        public float Label { get; set; } = 1.0f; // kako znati da je proizvod oznacen "svidja mi se"
    }
}

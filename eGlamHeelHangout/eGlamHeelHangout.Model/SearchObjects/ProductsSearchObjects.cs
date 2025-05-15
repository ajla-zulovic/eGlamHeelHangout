using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Model.SearchObjects
{
  public class ProductsSearchObjects :BaseSearchObject
  {
    public string ? Name { get; set; }
    public string? FTS { get; set; } // kada pretrazujemo i ako unesemo npr "a" izbacit ce nam rezultate gdje god naiđe na a - zato sluzi ovaj atribut
    public int? CategoryId { get; set; }
    }
}

// i name i FTS postavljamo na null "?" jer se ne moraju oba parametra unijeti u Get metodi kada pretrazujemo 

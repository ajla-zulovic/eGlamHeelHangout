using eGlamHeelHangout.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
  // "T" - generic parametar
  public interface IService<T, TSearch> where TSearch : class //ovdje kazemo da radimo s nekim tipom "T" ne interesuje nas sta je u biti 
  {
    Task<PagedResult<T>> Get(TSearch search=null); 
    Task<T> GetById(int id);
   Task<bool> Delete(int id);

    }
}

//TSearch search=null -> to ce biti filteri nad get metodom (naziv ili neki sl parametri)
// i u sustini =null jer ne moramo to unijeti :-) u tom slucaju ce vratiti sve !
// dakle, omogucili smo get metodi da primi neku genericku klasu kojom cemo filtrirati stvari

 using AutoMapper;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
  public class BaseCRUDService<T,TDb,TSearch,TInsert,TUpdate>:BaseService<T,TDb,TSearch> where TDb:class where T:class where TSearch:BaseSearchObject
  {
    public BaseCRUDService(_200199Context context, IMapper mapper):base(context,mapper)
    { }
    public virtual async Task BeforeInsert(TDb entity, TInsert insert)
    {
      //ova metoda nam sluzi da bismo lakse upravljali s djelom koda u insert metodi Hash and Salt 
    }

    public virtual async Task<T> Insert(TInsert insert)
    {
      var set = _context.Set<TDb>();
      TDb entity = _mapper.Map<TDb>(insert);
      set.Add(entity);
      await BeforeInsert(entity, insert);
      await _context.SaveChangesAsync();
      await _context.Entry(entity).ReloadAsync();
      return _mapper.Map<T>(entity);
    }

    public virtual async Task<T> Update(int id,TUpdate update)
    {
      var set = _context.Set<TDb>(); //dohvatimo zeljenu tabelu iz baze
      var entity = await set.FindAsync(id); //nađi entitet s trazenim id-om
      _mapper.Map(update, entity); //mapiraj ono sto se salje kao update u nas entitet kojeg smo pronasli u bazi
      await _context.SaveChangesAsync(); // spasi promjene
      return _mapper.Map<T>(entity); //vrati mapiranu vrijednost entity

    }
  }
}

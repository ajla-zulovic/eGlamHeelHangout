using AutoMapper;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
  public class BaseService<T,TDb,TSearch>:IService<T,TSearch> where TDb:class where T: class
    where TSearch:BaseSearchObject
    //dva genericka parametra - T->s kojom tabelom radimo i TDb-> gdje to mapiramo
  {
    protected _200199Context _context;
    protected IMapper _mapper { get; set; }
    public BaseService(_200199Context context, IMapper mapper)
    {
      _context = context;
      _mapper = mapper;
    }

    public virtual async Task<PagedResult<T>> Get(TSearch ? search=null) {
      var query = _context.Set<TDb>().AsQueryable();
      PagedResult<T> result = new PagedResult<T>();
      result.Count = await query.CountAsync();
      query = AddFilter(query, search);
      query = AddInclude(query, search);

      if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
      {
        query = query.Take(search.PageSize.Value).Skip(search.Page.Value * search.PageSize.Value);
      }

      var list = await query.ToListAsync();
      var tmp= _mapper.Map<List<T>>(list);
      result.Result = tmp;
      return result;
    }
    public virtual IQueryable<TDb> AddFilter(IQueryable<TDb> query, TSearch? search = null)
    {
      return query;
    }
    public virtual IQueryable<TDb> AddInclude(IQueryable<TDb> query, TSearch? search = null)
    {
      return query;
    }

    public virtual async Task<T> GetById(int id)
    {
      var entity = await _context.Set<TDb>().FindAsync(id);
      return _mapper.Map<T>(entity);

    }
  }
}

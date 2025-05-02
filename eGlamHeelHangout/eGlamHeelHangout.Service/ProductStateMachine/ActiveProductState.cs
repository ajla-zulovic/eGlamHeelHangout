using AutoMapper;
using eGlamHeelHangout.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service.ProductStateMachine
{
  public class ActiveProductState:BaseState
  {
    public IServiceProvider _serviceProvider { get; set; }
    public ActiveProductState(Database._200199Context context, IMapper mapper,IServiceProvider serviceProvider) : base(context, mapper,serviceProvider) { }
    public override Task<Products> Activate(int id)
    {
      return base.Activate(id);
    }

    public override async Task<Products> Hide(int id) //ovdje definisemo da cemo Hide metodom vratiti stanje proizvoda koje je bilo active u draft
    {
      var set = _context.Set<Database.Product>();
      var entity = await set.FindAsync(id);
      entity.StateMachine = "draft";
      await _context.SaveChangesAsync();
      return _mapper.Map<Model.Products>(entity);
    }

    public override async Task<List<string>> AllowedActions()
    {
      var list = await base.AllowedActions();
      list.Add("Hide");
      return list;

    }
  }
}

using AutoMapper;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Service.Database;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service.ProductStateMachine
{
  public class InitialProductStage:BaseState
  {
    public IServiceProvider _serviceProvider { get; set; }
    public InitialProductStage(Database._200199Context context, IMapper mapper,IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
    {
    }

    public override async Task<Products> Insert(ProductsInsertRequest request)
    {
      var set = _context.Set<Database.Product>();
      var entity = _mapper.Map<Database.Product>(request);
      entity.StateMachine = "draft";
      set.Add(entity);
      await _context.SaveChangesAsync();
      return _mapper.Map<Model.Products>(entity);

    }

    public override async Task<List<string>> AllowedActions()
    {
      var list = await base.AllowedActions();
      list.Add("Insert");
      return list;

    }
  }
}

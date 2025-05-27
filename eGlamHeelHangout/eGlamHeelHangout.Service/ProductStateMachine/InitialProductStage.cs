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
      entity.DateAdded = DateTime.Now;
      set.Add(entity);
      await _context.SaveChangesAsync();

            var validSizes = request.Sizes?.Where(s => s.StockQuantity > 0).ToList();

            if (validSizes != null && validSizes.Any())
            {
                foreach (var size in validSizes)
                {
                    var productSize = new ProductSize
                    {
                        ProductId = entity.ProductId,
                        Size = size.Size,
                        StockQuantity = size.StockQuantity
                    };
                    _context.ProductSizes.Add(productSize);
                }

                await _context.SaveChangesAsync();
            }
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

using AutoMapper;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Service.Database;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using RabbitMQ.Client;
using System.Text;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using System.Collections;
using System.Threading.Channels;
using EasyNetQ;
using Microsoft.EntityFrameworkCore;


namespace eGlamHeelHangout.Service.ProductStateMachine
{
  public class DraftProductState:BaseState
  {
    public IServiceProvider _serviceProvider { get; set; }
    protected ILogger<DraftProductState> _logger;
    public DraftProductState(ILogger<DraftProductState> logger,Database._200199Context context, IMapper mapper,IServiceProvider serviceProvider) :base(context,mapper, serviceProvider) {
      _logger = logger;
    }

        public override async Task<Products> Update(int id, ProductsUpdateRequest update)
        {
            var set = _context.Set<Database.Product>();
            var entity = await set.FindAsync(id);

            if (update.Name != null)
                entity.Name = update.Name;

            if (update.Description != null)
                entity.Description = update.Description;

            if (update.Price.HasValue)
                entity.Price = update.Price.Value;

            if (update.Image != null)
                entity.Image = update.Image;

            if (update.Price.HasValue)
            {
                if (update.Price.Value < 0)
                    throw new Exception("Price cannot be negative value");

                if (update.Price.Value < 1)
                    throw new UserException("Not valid price");
            }

            if (update.Sizes != null)
            {
                foreach (var s in update.Sizes)
                {
                    if (s.Size < 36 || s.Size > 46)
                        continue;

                    var existing = await _context.ProductSizes
                        .FirstOrDefaultAsync(x => x.ProductId == id && x.Size == s.Size);

                    if (existing != null)
                    {
                        existing.StockQuantity = s.StockQuantity;
                    }
                    else
                    {
                        var newSize = new ProductSize
                        {
                            ProductId = id,
                            Size = s.Size,
                            StockQuantity = s.StockQuantity
                        };

                        await _context.ProductSizes.AddAsync(newSize);
                    }
                }
            }

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                throw new Exception(ex.InnerException?.Message ?? ex.Message);
            }

            var sizes = await _context.ProductSizes
                .Where(x => x.ProductId == id)
                .Select(x => new ProductSizes
                {
                    Size = x.Size,
                    StockQuantity = x.StockQuantity
                })
                .ToListAsync();

            var result = _mapper.Map<Model.Products>(entity);
            result.Sizes = sizes;

            return result;
        }


        public override async Task<Model.Products> Activate(int id)
    {
      _logger.LogInformation($"Product activation:{id}");
      var set = _context.Set<Database.Product>();
      var entity = await set.FindAsync(id);
      entity.StateMachine = "active";
      await _context.SaveChangesAsync();
      var mappedEntity= _mapper.Map<Model.Products>(entity);

      using var bus = RabbitHutch.CreateBus("host=localhost");
         await bus.PubSub.PublishAsync(mappedEntity);        
     
      return mappedEntity;
    }
  

  public override async Task<List<string>> AllowedActions()
    {
      var list = await base.AllowedActions();
      list.Add("Update");
      list.Add("Activate");
      return list;

    }
  }
}

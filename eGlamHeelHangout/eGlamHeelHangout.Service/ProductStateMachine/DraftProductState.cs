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
      _mapper.Map(update, entity);
      if (entity.Price < 0)
      {
        throw new Exception("Price cannot be negative value"); //system exception 
      }

      if (entity.Price < 1)
      {
        throw new UserException("Not valid price"); //user exception, ono sto user moze vidjeti 
      }

      await _context.SaveChangesAsync();
      return _mapper.Map<Model.Products>(entity);
    }

    public override async Task<Model.Products> Activate(int id)
    {
      _logger.LogInformation($"Product activation:{id}");
      var set = _context.Set<Database.Product>();
      var entity = await set.FindAsync(id);
      entity.StateMachine = "active";
      await _context.SaveChangesAsync();

      // RabbitMQ communication
    //  var factory = new ConnectionFactory { HostName = "localhost" };
    //  using var connection = await factory.CreateConnectionAsync();
    //  using var channel = await connection.CreateChannelAsync();

    //  await channel.QueueDeclareAsync(queue: "product_added", durable: false, exclusive: false, autoDelete: false,
    //arguments: null);

    //  const string message = "Hello World!";
    //  var body = Encoding.UTF8.GetBytes(message);


    //  await channel.BasicPublishAsync(exchange: string.Empty, routingKey: "product_added", body: body);
     



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

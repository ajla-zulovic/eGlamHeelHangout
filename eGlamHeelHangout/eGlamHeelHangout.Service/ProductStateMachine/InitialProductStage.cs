using AutoMapper;
using EasyNetQ;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Service.Database;
using eGlamHeelHangout.Service.SignalR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
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
    private readonly IHubContext<GiveawayHub> _hubContext;
        public InitialProductStage(Database._200199Context context, IMapper mapper,IServiceProvider serviceProvider, IHubContext<GiveawayHub> hubContext) : base(context, mapper, serviceProvider)
    {
            _hubContext = hubContext;
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

            // RabbitMQ publish
            try
            {
                using var bus = RabbitHutch.CreateBus("host=rabbitmq;username=admin;password=admin123");
                Console.WriteLine(">>> Preparing to publish ProductNotificationDTO");
                Console.WriteLine($">>> Product: {entity.Name}, Price: {entity.Price}, ID: {entity.ProductId}");

                await bus.PubSub.PublishAsync(new ProductNotificationDTO
                {
                    ProductId = entity.ProductId,
                    Name = entity.Name,
                    Price = entity.Price,
                    Image = entity.Image != null ? Convert.ToBase64String(entity.Image) : null
                }, "product.new");

                Console.WriteLine("Published product notification to RabbitMQ.");
            }
            catch (Exception ex)
            {
                Console.WriteLine("RabbitMQ ERROR: " + ex.Message);
            }

            // Notifikacije u bazu  slanje SignalR popup poruka
            var users = await _context.Users
             .Where(u => u.UsersRoles.Any(ur => ur.Role.RoleName == "User"))
             .ToListAsync();

            foreach (var user in users)
            {
                var notification = new Notification
                {
                    UserId = user.UserId,
                    Message = $"New product '{entity.Name}' is now available!",
                    NotificationType = "NewProduct",
                    ProductId = entity.ProductId,
                    IsRead = false,
                    DateSent = DateTime.Now
                };

                _context.Notifications.Add(notification);
            }

            await _context.SaveChangesAsync();

            // SignalR po korisniku
            foreach (var user in users)
            {
                var notif = await _context.Notifications
                    .Where(n => n.UserId == user.UserId && n.ProductId == entity.ProductId)
                    .OrderByDescending(n => n.DateSent)
                    .FirstOrDefaultAsync();

                if (notif != null && _hubContext != null)
                {
                    Console.WriteLine(">>> Sending product via SignalR: " + entity.Name);
                    await _hubContext.Clients.User(user.Username).SendAsync("ReceiveProduct", new
                    {
                        notificationId = notif.NotificationId,
                        productId = entity.ProductId,
                        productName = entity.Name,
                        message = notif.Message,
                        dateSent = notif.DateSent?.ToString("yyyy-MM-ddTHH:mm:ss")
                    });
                }
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

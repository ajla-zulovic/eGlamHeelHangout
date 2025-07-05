using eGlamHeelHangout.Model;
using AutoMapper;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Service.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EasyNetQ;
using Microsoft.Extensions.Configuration;

namespace eGlamHeelHangout.Service
{
    public class DiscountService:IDiscountService
    {
        private readonly _200199Context _context;
        private readonly IMapper _mapper;
        private readonly IConfiguration _config;
        public DiscountService(_200199Context context, IMapper mapper,IConfiguration config)
        {
            _context = context;
            _mapper = mapper;
            _config = config;

        }
       
        public async Task AddDiscountAsync(DiscountInsertRequest request)
        {
            if (request.DiscountPercentage < 0 || request.DiscountPercentage > 70)
                throw new Exception("Discount must be between 0% and 70%.");

            if (request.StartDate.Date < DateTime.Now.Date)
                throw new Exception("Start date cannot be in the past.");

            if (request.EndDate.Date < request.StartDate.Date)
                throw new Exception("End date must be after start date.");

            var existing = await _context.Discounts
                .Where(x => x.ProductId == request.ProductId &&
                            x.EndDate >= DateTime.Now)
                .FirstOrDefaultAsync();

            if (existing != null)
                throw new Exception("This product already has an active discount.");

            var discount = new Discount
            {
                ProductId = request.ProductId,
                DiscountPercentage = request.DiscountPercentage,
                StartDate = request.StartDate,
                EndDate = request.EndDate
            };

            _context.Discounts.Add(discount);
            await _context.SaveChangesAsync();

       
            try
            {
                var rabbitHost = _config["RabbitMQ:HostName"];
                var rabbitPort = _config["RabbitMQ:Port"];
                var rabbitUser = _config["RabbitMQ:UserName"];
                var rabbitPass = _config["RabbitMQ:Password"];

                var rabbitConnection = $"host={rabbitHost};port={rabbitPort};username={rabbitUser};password={rabbitPass}";
                using var bus = RabbitHutch.CreateBus(rabbitConnection);

                var product = await _context.Products.FindAsync(discount.ProductId);

                if (product != null)
                {
                    await bus.PubSub.PublishAsync(new DiscountNotification
                    {
                        ProductId = product.ProductId,
                        ProductName = product.Name,
                        DiscountPercentage = (int)discount.DiscountPercentage,
                        Image = product.Image
                    }, "discount.new");

                    Console.WriteLine("Published discount notification to RabbitMQ.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("RabbitMQ ERROR (discount): " + ex.Message);
            }
        }


        public async Task<DiscountDTO?> GetByProductAsync(int productId)
        {
            var entity = await _context.Discounts
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.ProductId == productId);

            return _mapper.Map<DiscountDTO?>(entity);
        }

        public async Task RemoveDiscountAsync(int productId)
        {
            var discount = await _context.Discounts.FirstOrDefaultAsync(d => d.ProductId == productId);
            if (discount != null)
            {
                _context.Discounts.Remove(discount);
                await _context.SaveChangesAsync();
            }
        }

    }
}

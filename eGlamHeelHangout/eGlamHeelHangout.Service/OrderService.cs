using AutoMapper;
using eGlamHeelHangout.Model.Requests;
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
    public class OrderService : BaseCRUDService<Model.OrderDTO, Database.Order, Model.SearchObjects.OrderSearchObject, Model.Requests.OrderInsertRequest, object>,IOrderService
    {
        public OrderService(_200199Context context, IMapper mapper) : base(context, mapper) { }

        public override async Task<OrderDTO> Insert(OrderInsertRequest request)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var dbOrder = _mapper.Map<Order>(request);
                dbOrder.OrderStatus = "Pending";

                
                dbOrder.FullName = request.FullName;
                dbOrder.Email = request.Email;
                dbOrder.Address = request.Address;
                dbOrder.City = request.City;
                dbOrder.PostalCode = request.PostalCode;
                dbOrder.PhoneNumber = request.PhoneNumber;

                _context.Orders.Add(dbOrder);
                await _context.SaveChangesAsync();

                foreach (var item in request.Items)
                {
                    var dbItem = new OrderItem
                    {
                        OrderId = dbOrder.OrderId,
                        ProductId = item.ProductId,
                        ProductSizeId = item.ProductSizeId,
                        Quantity = item.Quantity,
                        PricePerUnit = item.PricePerUnit
                    };

                    var productSize = await _context.ProductSizes.FindAsync(item.ProductSizeId);
                    if (productSize == null || productSize.StockQuantity < item.Quantity)
                        throw new Exception("Not enough stock for selected size.");

                    productSize.StockQuantity -= item.Quantity;

                    _context.OrderItems.Add(dbItem);
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                var fullOrder = await _context.Orders
                    .Include(o => o.OrderItems).ThenInclude(oi => oi.Product)
                    .Include(o => o.OrderItems).ThenInclude(oi => oi.ProductSize)
                    .Include(o => o.User)
                    .FirstOrDefaultAsync(o => o.OrderId == dbOrder.OrderId);

                return _mapper.Map<OrderDTO>(fullOrder!);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        public override IQueryable<Order> AddFilter(IQueryable<Order> query, OrderSearchObject? search)
        {
            if (search == null)
                return base.AddFilter(query, search);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (!string.IsNullOrWhiteSpace(search.OrderStatus))
                query = query.Where(x => x.OrderStatus.ToLower().Contains(search.OrderStatus.ToLower()));

            if (!string.IsNullOrWhiteSpace(search.Username))
                query = query.Where(x => x.User.Username.ToLower().Contains(search.Username.ToLower()));

            return base.AddFilter(query, search);
        }

        public override IQueryable<Order> AddInclude(IQueryable<Order> query, Model.SearchObjects.OrderSearchObject? search = null)
        {
            return query
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.ProductSize)
                .Include(o => o.User);
        }
        public async Task<string> UpdateOrderStatusAsync(int orderId, string newStatus)
        {
            var order = await _context.Orders
                .Include(o => o.OrderItems)
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            if (order == null)
                throw new Exception("Order not found");

            if (!string.Equals(order.OrderStatus, "Pending", StringComparison.OrdinalIgnoreCase))
                throw new Exception("Only pending orders can be updated.");

            order.OrderStatus = newStatus;

            string message;
            if (string.Equals(newStatus, "Canceled", StringComparison.OrdinalIgnoreCase))
            {
                foreach (var it in order.OrderItems)
                {
                    var ps = await _context.ProductSizes.FindAsync(it.ProductSizeId);
                    if (ps != null) ps.StockQuantity += it.Quantity;
                }
                message = "Order canceled due to pricing error or unforeseen supply constraints  and stock restored.";
            }
            else if (string.Equals(newStatus, "Delivered", StringComparison.OrdinalIgnoreCase))
            {
                message = "Order marked as delivered.";
            }
            else
            {
                throw new Exception("Unsupported status.");
            }

            await _context.SaveChangesAsync();
            return message;
        }



    }
}



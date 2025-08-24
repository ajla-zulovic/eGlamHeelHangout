using eGlamHeelHangout.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
    public interface IOrderService: ICRUDService<OrderDTO, Model.SearchObjects.OrderSearchObject, Model.Requests.OrderInsertRequest, object>
    {
    
        Task<string> UpdateOrderStatusAsync(int orderId, string newStatus);

    }
}

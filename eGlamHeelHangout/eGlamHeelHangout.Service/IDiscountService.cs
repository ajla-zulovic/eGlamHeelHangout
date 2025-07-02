using eGlamHeelHangout.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eGlamHeelHangout.Model;
namespace eGlamHeelHangout.Service
{
    public interface IDiscountService
    {
        Task AddDiscountAsync(DiscountInsertRequest request);
        Task<DiscountDTO?> GetByProductAsync(int productId);
        Task RemoveDiscountAsync(int productId);

    }
}

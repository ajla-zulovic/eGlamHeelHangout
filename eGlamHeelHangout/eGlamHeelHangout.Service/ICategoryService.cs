using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{

    public interface ICategoryService : ICRUDService<Model.Categories, CategorySearchObject, CategoryInsertRequest, CategoryUpdateRequest>
    {
        Task<bool> Activate(int id);
        Task<bool> Deactivate(int id);

    }
}

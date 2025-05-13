using AutoMapper;
using eGlamHeelHangout.Service.Database;
using Microsoft.EntityFrameworkCore.Scaffolding.Metadata;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
    public class CategoryService:BaseService<Model.Categories,Database.Category,Model.SearchObjects.CategorySearchObject>,ICategoryService
    {
        public CategoryService(_200199Context contex, IMapper mapper):base(contex,mapper) {
            
        }
    }
}

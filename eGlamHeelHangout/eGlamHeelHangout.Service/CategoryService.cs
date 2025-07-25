using AutoMapper;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Scaffolding.Metadata;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eGlamHeelHangout.Service
{
    public class CategoryService : BaseCRUDService<Model.Categories, Database.Category, CategorySearchObject, CategoryInsertRequest, CategoryUpdateRequest>, ICategoryService

    {
        public CategoryService(_200199Context contex, IMapper mapper):base(contex,mapper) {
            
        }

        public override async Task BeforeInsert(Database.Category entity, CategoryInsertRequest insert)
        {
      
            bool exists = await _context.Categories
                .AnyAsync(c => c.CategoryName.ToLower() == insert.CategoryName.ToLower());

            if (exists)
            {
                throw new UserException($"Category '{insert.CategoryName}' already exists!");
            }
        }

        public override IQueryable<Database.Category> AddFilter(IQueryable<Database.Category> query, CategorySearchObject? search = null)
        {
            if (search?.IsActive.HasValue == true)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            return base.AddFilter(query, search);
        }
        public async Task<bool> Activate(int id)
        {
            var category = await _context.Categories.FindAsync(id);
            if (category == null)
                return false;

            category.IsActive = true;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> Deactivate(int id)
        {
            var category = await _context.Categories.FindAsync(id);
            if (category == null)
                return false;

            category.IsActive = false;
            await _context.SaveChangesAsync();
            return true;
        }


    }
}

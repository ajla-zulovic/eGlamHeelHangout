using AutoMapper;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service.Database;
using eGlamHeelHangout.Service.ProductStateMachine;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;


namespace eGlamHeelHangout.Service
{
  public class ProductService:BaseCRUDService<Model.Products,Database.Product,Model.SearchObjects.ProductsSearchObjects,Model.Requests.ProductsInsertRequest,Model.Requests.ProductsUpdateRequest>, IProductService
  {
    public BaseState _baseState { get; set; }
     private readonly IHttpContextAccessor _httpContextAccessor;
     private readonly IUserService _userService;

        public ProductService(_200199Context context, IMapper mapper, BaseState baseState, IHttpContextAccessor httpContextAccessor, IUserService userService) : base(context,mapper)
    {
      _baseState = baseState;
            _httpContextAccessor = httpContextAccessor;
            _userService = userService;
        }


    public override Task<Model.Products> Insert(ProductsInsertRequest insert)
    {
      var state = _baseState.CreateState("initial");
      return state.Insert(insert);
    }

    public override async Task<Model.Products> Update(int id, ProductsUpdateRequest update)
    {
      var entity = await _context.Products.FindAsync(id);
      var state = _baseState.CreateState(entity.StateMachine);
      return await state.Update(id, update);

    }

    public async Task<Model.Products> Activate(int id)
    {
      var entity = await _context.Products.FindAsync(id);

      var state = _baseState.CreateState(entity.StateMachine);

      return await state.Activate(id);
    }

    public async Task<Model.Products> Hide(int id)
    {
      var entity = await _context.Products.FindAsync(id); //dohvatimo/nađemo trazeni proizvod u nasoj bazi, tabeli Products

      var state = _baseState.CreateState(entity.StateMachine); //dohvatimo stanje tog prozivoda 

      return await state.Hide(id);  //to stanje koje smo imali pozivamo nad njim Hide metodu te ga vracamo u draft
    }

    public async Task<List<string>> AllowedActions(int id) //dopustene akcije za određeni proizvod, povratni tip je lista stringova jer su radnje opisane popit active,hide, draft i sl
    {
      var entity = await _context.Products.FindAsync(id);
      var state = _baseState.CreateState(entity?.StateMachine??"initial");
      return await state.AllowedActions();
    }
    public override IQueryable<Database.Product> AddFilter(IQueryable<Database.Product> query, ProductsSearchObjects? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.FTS));
            }
            if (search?.CategoryId.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.CategoryId == search.CategoryId);
            }

            return filteredQuery;
    }

     
        public async Task<List<Model.ProductSizes>> GetSizesForProductAsync(int productId)
        {
            return await _context.ProductSizes
                .Where(ps => ps.ProductId == productId)
                .Select(ps => new Model.ProductSizes
                {
                    Size = ps.Size,
                    StockQuantity = ps.StockQuantity
                })
                .ToListAsync();
        }
        public override async Task<PagedResult<Model.Products>> Get(ProductsSearchObjects? search = null)
        {
            var query = AddFilter(_context.Products.Include(p => p.ProductSizes).AsQueryable(), search);

            var toList = await query.ToListAsync();

            var username = _httpContextAccessor.HttpContext?.User.Identity?.Name;
            var userId = _userService.GetCurrentUserId(username);

            var favoriteIds = _context.Favorites
                .Where(f => f.UserId == userId)
                .Select(f => f.ProductId)
                .ToHashSet();

            var mapped = toList.Select(p =>
            {
                var mappedProduct = _mapper.Map<Model.Products>(p);
                mappedProduct.IsFavorite = favoriteIds.Contains(p.ProductId);
                return mappedProduct;
            }).ToList();

            return new PagedResult<Model.Products>
            {
                Count = mapped.Count,
                Result = mapped
            };
        }



    }
}

//AsQueryAble -> znaci da ce moci dodavati filtere

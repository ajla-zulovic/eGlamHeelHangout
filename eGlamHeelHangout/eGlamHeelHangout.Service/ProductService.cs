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
using Microsoft.ML;
using Microsoft.ML.Trainers;
using eGlamHeelHangout.Service.Recommender;


namespace eGlamHeelHangout.Service
{
    public class ProductService : BaseCRUDService<Model.Products, Database.Product, Model.SearchObjects.ProductsSearchObjects, Model.Requests.ProductsInsertRequest, Model.Requests.ProductsUpdateRequest>, IProductService
    {
        public BaseState _baseState { get; set; }
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IUserService _userService;

        public ProductService(_200199Context context, IMapper mapper, BaseState baseState, IHttpContextAccessor httpContextAccessor, IUserService userService) : base(context, mapper)
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
            var state = _baseState.CreateState(entity?.StateMachine ?? "initial");
            return await state.AllowedActions();
        }
        //public override IQueryable<Database.Product> AddFilter(IQueryable<Database.Product> query, ProductsSearchObjects? search = null)
        //{
        //    var filteredQuery = base.AddFilter(query, search);

        //    if (!string.IsNullOrWhiteSpace(search?.FTS))
        //    {
        //        filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.FTS));
        //    }
        //    if (search?.CategoryId.HasValue == true)
        //    {
        //        filteredQuery = filteredQuery.Where(x => x.CategoryId == search.CategoryId);
        //    }


        //    filteredQuery = filteredQuery.Where(x => !x.IsDeleted);

        //    return filteredQuery;
        //}
        // ProductService.cs
        public override IQueryable<Database.Product> AddFilter(
            IQueryable<Database.Product> query,
            ProductsSearchObjects? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.FTS));

            if (search?.CategoryId.HasValue == true)
                filteredQuery = filteredQuery.Where(x => x.CategoryId == search.CategoryId);

           
            if (search?.OnlyActiveCategories ?? true)
                filteredQuery = filteredQuery.Where(x => x.Category.IsActive);

        
            filteredQuery = filteredQuery.Where(x => !x.IsDeleted);

            return filteredQuery;
        }



        public async Task<List<Model.ProductSizes>> GetSizesForProductAsync(int productId)
        {
            return await _context.ProductSizes
                .Where(ps => ps.ProductId == productId)
                .Select(ps => new Model.ProductSizes
                {
                    ProductSizeId = ps.ProductSizeId,
                    Size = ps.Size,
                    StockQuantity = ps.StockQuantity
                })
                .ToListAsync();
        }


        public override async Task<PagedResult<Model.Products>> Get(ProductsSearchObjects? search = null)
        {
            var query = AddFilter(_context.Products.Include(p=>p.Category).Include(p => p.ProductSizes).AsQueryable(), search);

            var toList = await query.ToListAsync();

            var username = _httpContextAccessor.HttpContext?.User.Identity?.Name;
            var userId = _userService.GetCurrentUserId(username);

            var favoriteIds = _context.Favorites
                .Where(f => f.UserId == userId)
                .Select(f => f.ProductId)
                .ToHashSet();

            var currentDate = DateTime.Now;


            var mapped = toList.Select(p =>
            {
                var mappedProduct = _mapper.Map<Model.Products>(p);
                mappedProduct.IsFavorite = favoriteIds.Contains(p.ProductId);

                // Traži aktivni popust
                var discount = _context.Discounts
                    .Where(d => d.ProductId == p.ProductId && d.StartDate <= currentDate && d.EndDate >= currentDate)
                    .OrderByDescending(d => d.StartDate) 
                    .FirstOrDefault();

                if (discount != null)
                {
                    mappedProduct.DiscountPercentage = (int)discount.DiscountPercentage;
                    mappedProduct.DiscountedPrice = Math.Round(p.Price * (1 - discount.DiscountPercentage / 100.0m), 2);
                }


                return mappedProduct;
            }).ToList();

            return new PagedResult<Model.Products>
            {
                Count = mapped.Count(),
                Result = mapped
            };
        }

        public override async Task<Products> GetById(int id)
        {
            var product = await _context.Products
                .Include(p => p.Category)
                .FirstOrDefaultAsync(p => p.ProductId == id);

            if (product == null)
                throw new Exception("Product not found.");

            if (product.Category == null || !product.Category.IsActive)
                throw new Exception("Product is not available.");

            var dto = _mapper.Map<Products>(product);

         
            var discount = await _context.Discounts
                .Where(d => d.ProductId == id && d.StartDate <= DateTime.Now && d.EndDate >= DateTime.Now)
                .FirstOrDefaultAsync();

            if (discount != null)
            {
                dto.DiscountPercentage = (int)discount.DiscountPercentage;
                dto.DiscountedPrice = Math.Round(product.Price - (product.Price * (discount.DiscountPercentage / 100)), 2);
            }
            return dto;
        }

        static MLContext mlContext = null;
        static object isLocked = new object();
        static ITransformer model = null;

        public List<Model.Products> Recommend(int userId)
        {
            lock (isLocked)
            {
                if (mlContext == null)
                {
                    mlContext = new MLContext();

                    var data = _context.Favorites
                        .Where(f => !f.Product.IsDeleted && f.Product.Category.IsActive)
                        .Select(f => new ProductEntry
                        {
                            UserId = (uint)f.UserId,
                            ProductId = (uint)f.ProductId,
                            Label = 1f
                        })
                        .ToList();

                    if (!data.Any() || data.DistinctBy(d => new { d.UserId, d.ProductId }).Count() < 2)
                    {
                        return FallbackProducts();
                    }

                    var trainData = mlContext.Data.LoadFromEnumerable(data);

                    var options = new MatrixFactorizationTrainer.Options
                    {
                        MatrixColumnIndexColumnName = nameof(ProductEntry.ProductId),
                        MatrixRowIndexColumnName = nameof(ProductEntry.UserId),
                        LabelColumnName = nameof(ProductEntry.Label),
                        NumberOfIterations = 20,
                        ApproximationRank = 100
                    };

                    var est = mlContext.Recommendation().Trainers.MatrixFactorization(options);

                    try
                    {
                        model = est.Fit(trainData);
                    }
                    catch
                    {
                        return FallbackProducts();
                    }
                }
            }

            var userHasFavorites = _context.Favorites.Any(f => f.UserId == userId);

            if (!userHasFavorites)
                return FallbackProducts();

            var allProducts = _context.Products
                .Where(p => !p.IsDeleted && p.Category.IsActive)
                .ToList();

            var results = new List<Tuple<Product, float>>();

            if (model == null)
                return FallbackProducts();

            var predictionEngine = mlContext.Model.CreatePredictionEngine<ProductEntry, ProductScore>(model);

            foreach (var product in allProducts)
            {
                var prediction = predictionEngine.Predict(new ProductEntry
                {
                    UserId = (uint)userId,
                    ProductId = (uint)product.ProductId
                });

                results.Add(Tuple.Create(product, prediction.Score));
            }

            return results
                .Where(r => !_context.Favorites.Any(f => f.UserId == userId && f.ProductId == r.Item1.ProductId))
                .OrderByDescending(r => r.Item2)
                .Take(5)
                .Select(r =>
                {
                    var mapped = _mapper.Map<Model.Products>(r.Item1);

                    mapped.IsFavorite = _context.Favorites
                        .Any(f => f.UserId == userId && f.ProductId == r.Item1.ProductId);
                    var now = DateTime.Now.Date;
                    var discount = _context.Discounts
                        .Where(d => d.ProductId == r.Item1.ProductId &&
                                    d.StartDate.Date <= now &&
                                    d.EndDate.Date >= now)
                        .OrderByDescending(d => d.StartDate)
                        .FirstOrDefault();


                    if (discount != null)
                    {
                        mapped.DiscountPercentage = (int)discount.DiscountPercentage;
                        mapped.DiscountedPrice = Math.Round(mapped.Price * (1 - discount.DiscountPercentage / 100.0m), 2);
                    }

                    return mapped;
                })
                .ToList();
        }
        private List<Model.Products> FallbackProducts()
        {
            var now = DateTime.Now.Date;

            var topRated = _context.Products
                .Where(p => !p.IsDeleted && p.Category.IsActive)
                .Select(p => new
                {
                    Product = p,
                    AvgRating = _context.Reviews
                        .Where(r => r.ProductId == p.ProductId)
                        .Average(r => (double?)r.Rating) ?? 0
                })
                .OrderByDescending(p => p.AvgRating)
                .Take(5)
                .ToList(); 

            var result = topRated.Select(p =>
            {
                var mapped = _mapper.Map<Model.Products>(p.Product);

                var discount = _context.Discounts
                    .Where(d => d.ProductId == p.Product.ProductId &&
                                d.StartDate.Date <= now &&
                                d.EndDate.Date >= now)
                    .OrderByDescending(d => d.StartDate)
                    .FirstOrDefault();

                if (discount != null)
                {
                    mapped.DiscountPercentage = (int)discount.DiscountPercentage;
                    mapped.DiscountedPrice = Math.Round(mapped.Price * (1 - discount.DiscountPercentage / 100.0m), 2);
                }

                return mapped;
            }).ToList();

            return result;
        }

        public async Task<PagedResult<ProductDiscount>> GetWithDiscounts(ProductsSearchObjects? search = null)
        {
            var query = AddFilter(_context.Products.AsQueryable(), search);

            int totalCount = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var mapped = list.Select(p => new ProductDiscount
            {
                ProductId = p.ProductId,
                Name = p.Name,
                Price = p.Price,
                DiscountedPrice = _context.Discounts
                    .Where(d => d.ProductId == p.ProductId && d.StartDate <= DateTime.Now && d.EndDate >= DateTime.Now)
                    .Select(d => p.Price * (1 - d.DiscountPercentage / 100))
                    .FirstOrDefault(),

                DiscountPercentage = _context.Discounts
                    .Where(d => d.ProductId == p.ProductId && d.StartDate <= DateTime.Now && d.EndDate >= DateTime.Now)
                    .Select(d => (int?)d.DiscountPercentage)
                    .FirstOrDefault()
            }).ToList();

            return new PagedResult<ProductDiscount>
            {
                Count = totalCount,
                Result = mapped
            };
        }

        public override async Task<bool> Delete(int id)
        {
            var product = await _context.Products.FindAsync(id);

            if (product == null)
                return false;

            product.IsDeleted = true;
            await _context.SaveChangesAsync();

            return true;
        }

    }

}

//AsQueryAble -> znaci da ce moci dodavati filtere

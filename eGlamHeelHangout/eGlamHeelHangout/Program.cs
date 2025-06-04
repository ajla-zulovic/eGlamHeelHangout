using AutoMapper;
using eGlamHeelHangout;
using eGlamHeelHangout.Filters;
using eGlamHeelHangout.Model.Requests;
using eGlamHeelHangout.Model;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service;
using eGlamHeelHangout.Service.Database;
using eGlamHeelHangout.Service.ProductStateMachine;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Migrations.Operations;
using Microsoft.OpenApi.Models;
using eGlamHeelHangout.Model.Utilities;
using eGlamHeelHangout.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers(x => {
  x.Filters.Add<ErrorFilter>();
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle

builder.Services.Configure<StripeSettings>(builder.Configuration.GetSection("Stripe"));


builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
  c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
  {
    Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
    Scheme = "basic"
  });

  c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "basicAuth"
                }
            },
            new string[] {}
        }
    });
});
 
builder.Services.AddTransient<IProductService, ProductService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<IService<eGlamHeelHangout.Model.Categories,BaseSearchObject>,BaseService<eGlamHeelHangout.Model.Categories,eGlamHeelHangout.Service.Database.Category,BaseSearchObject>>();
builder.Services.AddTransient<BaseState>();
builder.Services.AddTransient<DraftProductState>();
builder.Services.AddTransient<InitialProductStage>();
builder.Services.AddTransient<ActiveProductState>();
builder.Services.AddTransient<IGiveawayService, GiveawayService>();
builder.Services.AddTransient<IFavoriteService, FavoriteService>();
builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<IOrderService, OrderService>();
builder.Services.AddTransient<IStripeService, StripeService>();



builder.Services.AddHttpContextAccessor();





var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<_200199Context>(options =>
options.UseSqlServer(connectionString));

builder.Services.AddAutoMapper(typeof(IUserService));
builder.Services.AddAuthentication("BasicAuthentication").AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);



var app = builder.Build();
using (var scope = app.Services.CreateScope())
{
    try
    {
        var mapper = scope.ServiceProvider.GetRequiredService<IMapper>();
        mapper.ConfigurationProvider.AssertConfigurationIsValid();
    }
    catch (AutoMapper.AutoMapperConfigurationException ex)
    {
        System.Diagnostics.Debug.WriteLine("AutoMapper greška u mapiranju:");
        System.Diagnostics.Debug.WriteLine(ex.Message);

        foreach (var error in ex.Errors)
        {
            var typeMap = error.TypeMap;
            if (typeMap != null)
            {
                var source = typeMap.SourceType?.Name ?? "???";
                var dest = typeMap.DestinationType?.Name ?? "???";

                System.Diagnostics.Debug.WriteLine($" {source} : {dest}");

                foreach (var unmapped in error.UnmappedPropertyNames)
                {
                    System.Diagnostics.Debug.WriteLine($"   - Unmapped: {unmapped}");
                }
            }
        }


        throw; // zadrži pad ako želiš da Swagger ne prikrije grešku
    }
}






// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
  app.UseSwagger();
  app.UseSwaggerUI();
}


app.UseHttpsRedirection();
app.UseStaticFiles(); //za slike

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

//ovo je za nas kreirati vse tabele koje su nam potrebne za rad aplikacije 
using (var scope = app.Services.CreateScope()) // kreira scope jer moj _200199Context ima scoped lifetime, sto znaci da postoji samo u okviru jednog scope-a ili request-a
{
  var dataContext = scope.ServiceProvider.GetRequiredService<_200199Context>();
    //dataContext.Database.EnsureCreated(); // provjerava da li baza postoji, ako ne postoji - kreira je
    //var conn = dataContext.Database.GetConnectionString();
    //dataContext.Database.Migrate(); // primijenjuje sve migracije na bazu 
    try
    {
        dataContext.Database.Migrate();
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Migration failed: {ex.Message}");
    }
}


app.MapControllers();
app.Run();

using eGlamHeelHangout;
using eGlamHeelHangout.Filters;
using eGlamHeelHangout.Model.SearchObjects;
using eGlamHeelHangout.Service;
using eGlamHeelHangout.Service.Database;
using eGlamHeelHangout.Service.ProductStateMachine;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Migrations.Operations;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers(x => {
  x.Filters.Add<ErrorFilter>();
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
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



var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<_200199Context>(options =>
options.UseSqlServer(connectionString));

builder.Services.AddAutoMapper(typeof(IUserService));
builder.Services.AddAuthentication("BasicAuthentication").AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

var app = builder.Build();

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
  var conn = dataContext.Database.GetConnectionString();
  //dataContext.Database.Migrate(); // primijenjuje sve migracije na bazu 
}


app.MapControllers();
app.Run();

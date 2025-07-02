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
using eGlamHeelHangout.Service.SignalR;
using QuestPDF.Infrastructure;
using DotNetEnv;


var builder = WebApplication.CreateBuilder(args);
Console.WriteLine(">>> ENVIRONMENT: " + builder.Environment.EnvironmentName);
var envPath = Path.Combine(AppContext.BaseDirectory, "../../../../.env");
Console.WriteLine("ENV FILE: " + envPath);
Env.Load(envPath);

Console.WriteLine(" Loaded SecretKey: " + Environment.GetEnvironmentVariable("Stripe__SecretKey"));

builder.Configuration
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddEnvironmentVariables() //da moze citati pub_key iz .env fajla
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables();

QuestPDF.Settings.License = LicenseType.Community;


builder.Services.AddControllers(x => {
  x.Filters.Add<ErrorFilter>();
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle

var stripeSecretKey = Environment.GetEnvironmentVariable("Stripe__SecretKey");
var stripePublishableKey = Environment.GetEnvironmentVariable("Stripe__PublishableKey");

if (string.IsNullOrEmpty(stripeSecretKey) || string.IsNullOrEmpty(stripePublishableKey))
{
    Console.WriteLine("Stripe kljucevi nisu ucitani iz .env fajla. Provjeri putanju ili sadrzaj fajla.");
}

if (!string.IsNullOrEmpty(stripeSecretKey) && !string.IsNullOrEmpty(stripePublishableKey))
{
    builder.Services.Configure<StripeSettings>(options =>
    {
        options.SecretKey = stripeSecretKey;
        options.PublishableKey = stripePublishableKey;
    });
}
else
{
    builder.Services.Configure<StripeSettings>(builder.Configuration.GetSection("Stripe"));
}


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
builder.Services.AddTransient<IReportService, ReportService>();
builder.Services.AddTransient<IDiscountService, DiscountService>();

builder.Services.AddSignalR();



builder.Services.AddHttpContextAccessor();


builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.SetIsOriginAllowed(_ => true)
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();

    });
});




var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
Console.WriteLine(">>> KONEKCIJSKI STRING: " + connectionString);
builder.Services.AddDbContext<_200199Context>(options =>
options.UseSqlServer(connectionString));



builder.Services.AddAutoMapper(typeof(IUserService));
builder.Services.AddAuthentication("BasicAuthentication").AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);



var app = builder.Build();
app.Urls.Add("http://0.0.0.0:7277");
using (var scope = app.Services.CreateScope())
{
    try
    {
        var mapper = scope.ServiceProvider.GetRequiredService<IMapper>();
        mapper.ConfigurationProvider.AssertConfigurationIsValid();
    }
    catch (AutoMapper.AutoMapperConfigurationException ex)
    {
        System.Diagnostics.Debug.WriteLine("AutoMapper greska u mapiranju:");
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


        throw;
    }
}
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment() || app.Environment.EnvironmentName == "Docker")
{
  app.UseSwagger();
  app.UseSwaggerUI();
}


//app.UseHttpsRedirection();
app.UseStaticFiles(); //za slike
app.UseRouting();
app.UseCors("AllowAll");


app.UseAuthentication();
app.UseAuthorization();

app.UseEndpoints(endpoints =>
{
    endpoints.MapControllers();
    endpoints.MapHub<GiveawayHub>("/giveawayHub");
});

//ovo je za nas kreirati vse tabele koje su nam potrebne za rad aplikacije 
using (var scope = app.Services.CreateScope()) // kreira scope jer moj _200199Context ima scoped lifetime, sto znaci da postoji samo u okviru jednog scope-a ili request-a
{
    var dataContext = scope.ServiceProvider.GetRequiredService<_200199Context>();
    try
    {
        Console.WriteLine(">>> Running DB migration...");
        dataContext.Database.Migrate();
        Console.WriteLine(">>> Migration successful.");
    }
    catch (Exception ex)
    {
        Console.WriteLine(">>> Migration failed:");
        Console.WriteLine(ex.ToString());
    }
}




app.Run();

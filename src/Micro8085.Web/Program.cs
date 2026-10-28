using Micro8085.Core.Storage;
using Micro8085.Web.Infrastructure;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddControllersWithViews(options => options.Filters.Add(new AutoValidateAntiforgeryTokenAttribute()))
    .AddJsonOptions(options => JsonDefaults.Configure(options.JsonSerializerOptions));
builder.Services.AddAntiforgery(options => options.HeaderName = "X-CSRF-TOKEN");
builder.Services.AddMemoryCache();
builder.Services.AddSingleton<MonitorSessionStore>();
var seedDirectory = Path.Combine(AppContext.BaseDirectory, "SeedPrograms");
builder.Services.AddSingleton(new OriginalPrograms(seedDirectory));
builder.Services.AddSingleton(services =>
{
    var environment = services.GetRequiredService<IWebHostEnvironment>();
    var configured = builder.Configuration["Programs:Directory"] ?? "App_Data/Programs";
    var directory = Path.GetFullPath(configured, environment.ContentRootPath);
    ProgramSeeder.SeedIfEmpty(directory, seedDirectory);
    return new ProgramCatalog(directory);
});

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.Run();

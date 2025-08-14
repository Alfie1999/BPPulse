using BPandPulseApi;
using BPandPulseApi.Data;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

public class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(Microsoft.AspNetCore.Hosting.IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing"); // use InMemory DB

        builder.ConfigureServices(services =>
        {
            // Remove existing DbContext
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<ReadingsContext>));
            if (descriptor != null)
                services.Remove(descriptor);

            services.AddDbContext<ReadingsContext>(options =>
                options.UseInMemoryDatabase("TestDb"));

            // Ensure DB is created
            var sp = services.BuildServiceProvider();
            using var scope = sp.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ReadingsContext>();
            db.Database.EnsureCreated();
        });
    }
}

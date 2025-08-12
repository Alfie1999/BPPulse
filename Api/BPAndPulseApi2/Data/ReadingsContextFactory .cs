using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace HealthReadingsApi.Data
{
    public class ReadingsContextFactory : IDesignTimeDbContextFactory<ReadingsContext>
    {
        public ReadingsContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<ReadingsContext>();

            // Put your actual connection string here
            optionsBuilder.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=HealthReadingsDb;Trusted_Connection=True;");

            return new ReadingsContext(optionsBuilder.Options);
        }
    }
}

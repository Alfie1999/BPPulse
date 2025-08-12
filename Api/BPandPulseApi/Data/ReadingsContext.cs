using Microsoft.EntityFrameworkCore;
using HealthReadingsApi.Models;

namespace HealthReadingsApi.Data
{
    public class ReadingsContext : DbContext
    {
        public ReadingsContext(DbContextOptions<ReadingsContext> options) : base(options)
        {
        }

        public DbSet<Reading> Readings { get; set; }
    }
}

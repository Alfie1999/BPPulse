using BPandPulseApi.Models;
using Microsoft.EntityFrameworkCore;

namespace BPandPulseApi.Data
{
    public class ReadingsContext : DbContext
    {
        public ReadingsContext(DbContextOptions<ReadingsContext> options) : base(options)
        {
        }

        public DbSet<Reading> Readings { get; set; }
    }
}


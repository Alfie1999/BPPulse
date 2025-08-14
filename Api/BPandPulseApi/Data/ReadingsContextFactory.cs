using Microsoft.EntityFrameworkCore;
using BPandPulseApi.Models;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Design;

namespace BPandPulseApi.Data
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

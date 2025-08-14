using Microsoft.EntityFrameworkCore;
using BPandPulseApi.Models;
using System.Collections.Generic;

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


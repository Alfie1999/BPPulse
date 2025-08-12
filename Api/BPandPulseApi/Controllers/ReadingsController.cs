using Microsoft.AspNetCore.Mvc;
using HealthReadingsApi.Models;
using HealthReadingsApi.Data;
using Microsoft.EntityFrameworkCore;

namespace HealthReadingsApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReadingsController : ControllerBase
    {
        private readonly ReadingsContext _context;

        public ReadingsController(ReadingsContext context)
        {
            _context = context;
        }

        [HttpPost("saveReading")]
        public async Task<IActionResult> SaveReading([FromBody] Reading reading)
        {
            _context.Readings.Add(reading);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Reading saved successfully" });
        }

        // Optional: Get all readings
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var readings = await _context.Readings.ToListAsync();
            return Ok(readings);
        }
    }
}

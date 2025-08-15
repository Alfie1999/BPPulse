using Microsoft.AspNetCore.Mvc;
using BPandPulseApi.Models;
using BPandPulseApi.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using System;

namespace BPandPulseApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReadingsController : ControllerBase
    {
        private readonly ReadingsContext _context;
        private readonly ILogger<ReadingsController> _logger;

        public ReadingsController(ReadingsContext context, ILogger<ReadingsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpPost("saveReading")]
        public async Task<IActionResult> SaveReading([FromBody] CreateReadingDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Custom validation: no negative values allowed
            if (dto.Systolic < 0 || dto.Diastolic < 0 || dto.Pulse < 0)
            {
                return BadRequest("Systolic, Diastolic, and Pulse values must be non-negative.");
            }

            try
            {
                var reading = new Reading
                {
                    Systolic = dto.Systolic,
                    Diastolic = dto.Diastolic,
                    Pulse = dto.Pulse
                };

                _context.Readings.Add(reading);
                int savedRecords = await _context.SaveChangesAsync();

                if (savedRecords > 0)
                {
                    // Return Created with new reading's ID
                    _logger.LogInformation("saving reading");
                    return CreatedAtAction(nameof(GetReadingById), new { id = reading.Id }, reading);
                }
                else
                {
                    return StatusCode(500, new { error = "Failed to save record." });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving reading");
                return StatusCode(500, new { error = "Failed to save record." });
            }
        }

        [HttpGet("GetAll")]
        public async Task<IActionResult> GetAll()
        {
            var readings = await _context.Readings.ToListAsync();
            return Ok(readings);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetReadingById(int id)
        {
            var reading = await _context.Readings.FindAsync(id);

            if (reading == null)
                return NotFound();

            return Ok(reading);
        }
    }
}

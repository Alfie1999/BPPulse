using BPandPulseApi.Controllers;
using BPandPulseApi.Data;
using BPandPulseApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace BPandPulseApi.Tests
{
    // This test class tests the ReadingsController directly, without spinning up an HTTP server.
    public class ReadingsControllerTests
    {
        // Creates a new in-memory database context for each test.
        // Using a unique database name ensures test isolation.
        private ReadingsContext GetInMemoryContext()
        {
            var options = new DbContextOptionsBuilder<ReadingsContext>()
                .UseInMemoryDatabase(databaseName: System.Guid.NewGuid().ToString()) // Unique DB per test
                .Options;

            var context = new ReadingsContext(options);
            context.Database.EnsureCreated(); // Ensure DB schema exists
            return context;
        }

        // Creates a controller instance with the provided in-memory context
        private ReadingsController GetController(ReadingsContext context)
        {
            // Create a logger for the controller
            var logger = LoggerFactory.Create(builder => builder.AddConsole())
                                      .CreateLogger<ReadingsController>();
            return new ReadingsController(context, logger);
        }

        // Test: Saving a valid reading returns a CreatedAtActionResult with the correct data
        [Fact]
        public async Task SaveReading_ValidDto_ReturnsCreatedAtAction()
        {
            // Arrange: prepare context, controller, and input DTO
            var context = GetInMemoryContext();
            var controller = GetController(context);
            var dto = new CreateReadingDto
            {
                Systolic = 120,
                Diastolic = 80,
                Pulse = 70
            };

            // Act: call the SaveReading method
            var result = await controller.SaveReading(dto);

            // Assert: check that the result is CreatedAtActionResult and data matches input
            var createdResult = Assert.IsType<CreatedAtActionResult>(result);
            var reading = Assert.IsType<Reading>(createdResult.Value);
            Assert.Equal(120, reading.Systolic);
            Assert.Equal(80, reading.Diastolic);
            Assert.Equal(70, reading.Pulse);
        }

        // Test: GetAll returns all readings as OkObjectResult
        [Fact]
        public async Task GetAll_WhenDataExists_ReturnsOkWithData()
        {
            // Arrange: seed the in-memory DB with two readings
            var context = GetInMemoryContext();
            context.Readings.Add(new Reading { Systolic = 110, Diastolic = 70, Pulse = 60 });
            context.Readings.Add(new Reading { Systolic = 130, Diastolic = 85, Pulse = 72 });
            await context.SaveChangesAsync();

            var controller = GetController(context);

            // Act: call GetAll method
            var result = await controller.GetAll();

            // Assert: ensure OkObjectResult is returned and contains 2 readings
            var okResult = Assert.IsType<OkObjectResult>(result);
            var readings = Assert.IsAssignableFrom<List<Reading>>(okResult.Value);
            Assert.Equal(2, readings.Count);
        }

        // Test: GetReadingById returns OkObjectResult for a valid ID
        [Fact]
        public async Task GetReadingById_ValidId_ReturnsOk()
        {
            // Arrange: seed the DB with a reading
            var context = GetInMemoryContext();
            var reading = new Reading { Systolic = 125, Diastolic = 82, Pulse = 65 };
            context.Readings.Add(reading);
            await context.SaveChangesAsync();

            var controller = GetController(context);

            // Act: retrieve reading by its ID
            var result = await controller.GetReadingById(reading.Id);

            // Assert: ensure result is OkObjectResult and reading matches
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnedReading = Assert.IsType<Reading>(okResult.Value);
            Assert.Equal(reading.Id, returnedReading.Id);
        }

        // Test: GetReadingById returns NotFoundResult for an invalid ID
        [Fact]
        public async Task GetReadingById_InvalidId_ReturnsNotFound()
        {
            // Arrange: create empty context and controller
            var context = GetInMemoryContext();
            var controller = GetController(context);

            // Act: attempt to get a non-existing reading
            var result = await controller.GetReadingById(999);

            // Assert: ensure NotFoundResult is returned
            Assert.IsType<NotFoundResult>(result);
        }

        // Test:ReturnsBadRequestreturns ReturnsBadRequest for an invalid dto
        [Fact]
        public async Task SaveReading_InvalidDto_ReturnsBadRequest()
        {
            // Arrange
            var context = GetInMemoryContext();
            var controller = GetController(context);
            var invalidDto = new CreateReadingDto
            {
                Systolic = -120,
                Diastolic = -80,
                Pulse = -70
            };

            // Act
            var result = await controller.SaveReading(invalidDto);

            // Assert
            Assert.IsType<BadRequestObjectResult>(result);
        }
    }
}

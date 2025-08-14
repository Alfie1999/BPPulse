using BPandPulseApi.Controllers;
using BPandPulseApi.Data;
using BPandPulseApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace BPandPulseApi.Tests
{
    public class ReadingsControllerTests 
    {
        private ReadingsContext GetInMemoryContext()
        {
            var options = new DbContextOptionsBuilder<ReadingsContext>()
                .UseInMemoryDatabase(databaseName: System.Guid.NewGuid().ToString()) // unique DB per test
                .Options;

            var context = new ReadingsContext(options);
            context.Database.EnsureCreated();
            return context;
        }

        private ReadingsController GetController(ReadingsContext context)
        {
            var logger = LoggerFactory.Create(builder => builder.AddConsole()).CreateLogger<ReadingsController>();
            return new ReadingsController(context, logger);
        }

        [Fact]
        public async Task SaveReading_ValidDto_ReturnsCreatedAtAction()
        {
            // Arrange
            var context = GetInMemoryContext();
            var controller = GetController(context);
            var dto = new CreateReadingDto
            {
                Systolic = 120,
                Diastolic = 80,
                Pulse = 70
            };

            // Act
            var result = await controller.SaveReading(dto);

            // Assert
            var createdResult = Assert.IsType<CreatedAtActionResult>(result);
            var reading = Assert.IsType<Reading>(createdResult.Value);
            Assert.Equal(120, reading.Systolic);
            Assert.Equal(80, reading.Diastolic);
            Assert.Equal(70, reading.Pulse);
        }

        [Fact]
        public async Task GetAll_WhenDataExists_ReturnsOkWithData()
        {
            // Arrange
            var context = GetInMemoryContext();
            context.Readings.Add(new Reading { Systolic = 110, Diastolic = 70, Pulse = 60 });
            context.Readings.Add(new Reading { Systolic = 130, Diastolic = 85, Pulse = 72 });
            await context.SaveChangesAsync();

            var controller = GetController(context);

            // Act
            var result = await controller.GetAll();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var readings = Assert.IsAssignableFrom<List<Reading>>(okResult.Value);
            Assert.Equal(2, readings.Count);
        }

        [Fact]
        public async Task GetReadingById_ValidId_ReturnsOk()
        {
            // Arrange
            var context = GetInMemoryContext();
            var reading = new Reading { Systolic = 125, Diastolic = 82, Pulse = 65 };
            context.Readings.Add(reading);
            await context.SaveChangesAsync();

            var controller = GetController(context);

            // Act
            var result = await controller.GetReadingById(reading.Id);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnedReading = Assert.IsType<Reading>(okResult.Value);
            Assert.Equal(reading.Id, returnedReading.Id);
        }

        [Fact]
        public async Task GetReadingById_InvalidId_ReturnsNotFound()
        {
            // Arrange
            var context = GetInMemoryContext();
            var controller = GetController(context);

            // Act
            var result = await controller.GetReadingById(999);

            // Assert
            Assert.IsType<NotFoundResult>(result);
        }
    }
}

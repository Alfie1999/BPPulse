using BPandPulseApi.Data;
using BPandPulseApi.Models;
using Microsoft.Extensions.DependencyInjection;
using System.Net;
using System.Net.Http.Json;

// Test class using xUnit's IClassFixture<T> to share a single test server instance.
// CustomWebApplicationFactory sets up an in-memory test server for the API.
public class ReadingsControllerTests : IClassFixture<CustomWebApplicationFactory>
{
    private readonly HttpClient _client;                   // Used to send HTTP requests to the test server
    private readonly CustomWebApplicationFactory _factory; // Factory for creating the test server and services

    // Constructor receives the shared factory from xUnit
    public ReadingsControllerTests(CustomWebApplicationFactory factory)
    {
        _factory = factory;
        _client = _factory.CreateClient(); // Create a single HttpClient per test class
    }

    // Example test: verifies that retrieving a reading works correctly
    [Fact]
    public async Task GetReadings_ReturnsSuccess()
    {
        // Arrange: seed the in-memory database with test data
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ReadingsContext>();

        // Ensure database is clean before seeding
        db.Database.EnsureDeleted();
        db.Database.EnsureCreated();

        // Add a sample reading to the database
        db.Readings.Add(new Reading
        {
            Systolic = 120,
            Diastolic = 80,
            Pulse = 70,
            Id = 1
        });
        db.SaveChanges();

        // Act: send an HTTP GET request to the API endpoint
        var response = await _client.GetAsync("/api/readings/1");

        // Assert: ensure the response was successful (HTTP 200)
        response.EnsureSuccessStatusCode();

        // Optional: verify the response content
        var reading = await response.Content.ReadFromJsonAsync<Reading>();
        Assert.NotNull(reading);
        Assert.Equal(120, reading.Systolic);
        Assert.Equal(80, reading.Diastolic);
        Assert.Equal(70, reading.Pulse);
    }

    // Test: verifies that creating a reading via POST works correctly
    [Fact]
    public async Task SaveReadings_ReturnsCreatedReading()
    {
        // Arrange: create a DTO representing the reading to save
        var readingDto = new CreateReadingDto
        {
            Systolic = 120,
            Diastolic = 80,
            Pulse = 70
        };

        // Act: send POST request with the DTO as JSON
        var response = await _client.PostAsJsonAsync("/api/readings/saveReading", readingDto);

        // Assert: ensure the response indicates success (HTTP 201 Created)
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        // Optional: deserialize the returned reading and verify its properties
        var createdReading = await response.Content.ReadFromJsonAsync<Reading>();
        Assert.NotNull(createdReading);
        Assert.Equal(120, createdReading.Systolic);
        Assert.Equal(80, createdReading.Diastolic);
        Assert.Equal(70, createdReading.Pulse);
        Assert.True(createdReading.Id > 0); // ID should be set by the database
    }


    // Test: verifies that getting a reading via get with Id that does not exist in the DB
    [Fact]
    public async Task GetReadings_NotFound_Returns404()
    {
        // Act: try to get a reading that doesn't exist
        var response = await _client.GetAsync("/api/readings/999");

        // Assert: should return 404 Not Found
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }
    // Test: verifies that getting a reading via post with an invalid dto returns 400 Bad Request
    [Fact]
    public async Task SaveReadings_InvalidInput_Returns400()
    {
        // Arrange: create an invalid DTO (e.g., negative values)
        var invalidReadingDto = new CreateReadingDto
        {
            Systolic = -10,
            Diastolic = -5,
            Pulse = -20
        };

        // Act: send POST request with invalid data
        var response = await _client.PostAsJsonAsync("/api/readings/saveReading", invalidReadingDto);

        // Assert: should return 400 Bad Request
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task SaveReadings_MissingFields_Returns400()
    {
        // Arrange: create a DTO with missing Systolic
        var readingDto = new CreateReadingDto
        {
            // Systolic is missing
            Diastolic = 80,
            Pulse = 70
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/readings/saveReading", readingDto);

        // Assert
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}

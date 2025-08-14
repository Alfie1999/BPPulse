using BPandPulseApi.Data;
using BPandPulseApi.Models;
using Microsoft.Extensions.DependencyInjection;


public class ReadingsControllerTests : IClassFixture<CustomWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly CustomWebApplicationFactory _factory;

    public ReadingsControllerTests(CustomWebApplicationFactory factory)
    {
        _factory = factory;                     // ✅ Single factory for all tests
        _client = _factory.CreateClient();      // ✅ Only one HttpClient per test class
    }

    [Fact]
    public async Task GetReadings_ReturnsSuccess()
    {

        // Arrange — seed in-memory database
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ReadingsContext>();

        // Clear the database
        db.Database.EnsureDeleted();
        db.Database.EnsureCreated();

        db.Readings.Add(new Reading
        {
            Systolic = 120,
            Diastolic = 80,
            Pulse = 70,
            Id = 1
        });
        db.SaveChanges();
        var response = await _client.GetAsync("/api/readings/1");
        response.EnsureSuccessStatusCode();
    }
}



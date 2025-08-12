namespace HealthReadingsApi.Models
{
    public class Reading
    {
        public int Id { get; set; }         // Add this so EF Core has a primary key
        public int Systolic { get; set; }
        public int Diastolic { get; set; }
        public int Pulse { get; set; }
    }
}
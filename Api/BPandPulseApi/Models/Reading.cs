using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace BPandPulseApi.Models
{
    public class Reading
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }         // Add this so EF Core has a primary key
        public int Systolic { get; set; }
        public int Diastolic { get; set; }
        public int Pulse { get; set; }
    }
}

using System.ComponentModel.DataAnnotations;

namespace BPandPulseApi.Models
{
    public class CreateReadingDto
    {
        [Required]
        public int Systolic { get; set; }

        [Required]
        public int Diastolic { get; set; }

        [Required]
        public int Pulse { get; set; }
    }
}

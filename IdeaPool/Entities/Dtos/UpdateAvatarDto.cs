using System.ComponentModel.DataAnnotations;

namespace Entities.Dtos
{
    public class UpdateAvatarDto
    {
        [Required]
        public string AvatarUrl { get; set; } = string.Empty;
    }
}

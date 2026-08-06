using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Models
{
    public class User
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;

        // IdentityServer kullanmadan sıfırdan Auth için şifre hash alanları:
        public byte[] PasswordHash { get; set; } = Array.Empty<byte>();
        public byte[] PasswordSalt { get; set; } = Array.Empty<byte>();

        public string Phone { get; set; } = string.Empty;
        public string RegistrationNumber { get; set; } = string.Empty; // Sicil No
        public string IdentityNumber { get; set; } = string.Empty;     // T.C. Kimlik No
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public ICollection<UserPermission> UserPermissions { get; set; } = new List<UserPermission>();
        public ICollection<Idea> Ideas { get; set; } = new List<Idea>();
    }

}

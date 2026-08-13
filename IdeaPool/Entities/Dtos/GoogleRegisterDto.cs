using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Dtos
{
    public class GoogleRegisterDto
    {
        public string IdToken { get; set; } = string.Empty; // Güvenlik için tekrar yollanır
        public string Phone { get; set; } = string.Empty;
        public string RegistrationNumber { get; set; } = string.Empty; // Sicil No
        public string IdentityNumber { get; set; } = string.Empty;     // T.C. Kimlik
    }

}

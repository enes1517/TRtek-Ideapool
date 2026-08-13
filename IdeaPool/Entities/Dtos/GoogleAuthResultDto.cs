using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Dtos
{
    public class GoogleAuthResultDto
    {
        // Eğer giriş başarılıysa direkt token döner.
        public LoginResponseDto? LoginResponse { get; set; }
        // Eğer kullanıcı veritabanında yoksa, bu True gelir.
        public bool RequiresRegistration { get; set; }
        // Frontend'in formda hazır göstermesi için Google'dan aldığımız veriler:
        public string? Email { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
    }

}

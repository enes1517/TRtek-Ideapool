using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services.Infrastructure.Exceptions
{
    public  class NotFoundException(string message) : Exception(message);
    public  class BadRequestException(string message) : Exception(message);
    public  class UnauthorizedException(string message) : Exception(message);

    // Örnek Somut Sınıf:
    public class UserNotFoundException : NotFoundException
    {
        public UserNotFoundException(int id) : base($"Id={id} olan kullanıcı bulunamadı.") { }
    }

}

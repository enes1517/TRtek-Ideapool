using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Dtos
{
    public class LoginResponseDto
    {
        public string Token { get; set; }       // JWT
        public UserResponseDto User { get; set; }
        public List<string> Permissions { get; set; }
    }



}

using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services.Contracts
{
    public interface IJwtService
    {
        string GenerateToken(User user, List<string> permissions);
        int? GetUserIdFromToken(string token);
        List<string> GetPermissionsFromToken(string token);
    }

}

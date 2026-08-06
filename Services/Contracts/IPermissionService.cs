using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services.Contracts
{
    public interface IPermissionService
    {
        Task<List<Permission>> GetAllPermissionsAsync();
        Task<List<Permission>> GetUserPermissionsAsync(int userId);
        Task GrantPermissionAsync(int userId, int permissionId);
        Task RevokePermissionAsync(int userId, int permissionId);
    }
}

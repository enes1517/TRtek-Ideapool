using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories.Contracts
{
    public interface IPermissionRepository : IRepositoryBase<Permission>
    {
        Task<List<Permission>> GetAllPermissionsAsync(bool trackChanges);
        Task<List<Permission>> GetUserPermissionsAsync(int userId, bool trackChanges);
        void GrantPermissionToUser(int userId, int permissionId);
        void RevokePermissionFromUser(int userId, int permissionId);
    }
}

using Entities.Models;
using Repositories.Contracts;
using Services.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services
{
    public class PermissionService : IPermissionService
    {
        private readonly IRepositoryManager _repo;
        public PermissionService(IRepositoryManager repo) => _repo = repo;
        public async Task<List<Permission>> GetAllPermissionsAsync() =>
            await _repo.Permission.GetAllPermissionsAsync(false);
        public async Task<List<Permission>> GetUserPermissionsAsync(int userId) =>
            await _repo.Permission.GetUserPermissionsAsync(userId, false);
        public async Task GrantPermissionAsync(int userId, int permissionId)
        {
            _repo.Permission.GrantPermissionToUser(userId, permissionId);
            await _repo.SaveAsync();
        }
        public async Task RevokePermissionAsync(int userId, int permissionId)
        {
            _repo.Permission.RevokePermissionFromUser(userId, permissionId);
            await _repo.SaveAsync();
        }
    }

}

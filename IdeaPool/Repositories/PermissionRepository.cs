using Entities.Models;
using Microsoft.EntityFrameworkCore;
using Repositories.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories
{
    public class PermissionRepository : RepositoryBase<Permission>, IPermissionRepository
    {
        public PermissionRepository(RepositoryContext context) : base(context) { }
        public async Task<List<Permission>> GetAllPermissionsAsync(bool trackChanges) =>
            await FindAll(trackChanges).ToListAsync();
        public async Task<List<Permission>> GetUserPermissionsAsync(int userId, bool trackChanges) =>
            await _context.UserPermissions
                .Where(up => up.UserId == userId)
                .Select(up => up.Permission)
                .ToListAsync();
        public void GrantPermissionToUser(int userId, int permissionId) =>
            _context.UserPermissions.Add(new UserPermission { UserId = userId, PermissionId = permissionId });
        public void RevokePermissionFromUser(int userId, int permissionId)
        {
            var entity = _context.UserPermissions.FirstOrDefault(up => up.UserId == userId && up.PermissionId == permissionId);
            if (entity != null) _context.UserPermissions.Remove(entity);
        }
    }

}

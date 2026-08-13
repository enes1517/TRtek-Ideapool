using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories.Contracts
{
    public interface IUserRepository : IRepositoryBase<User>
    {
        Task<List<User>> GetAllUsersAsync(bool trackChanges);
        Task<User?> GetUserByIdAsync(int id, bool trackChanges);
        Task<User?> GetUserWithFavoritesAsync(int id, bool trackChanges);
        Task<User?> GetUserByEmailAsync(string email, bool trackChanges);
        void CreateOneUser(User user);
        void UpdateOneUser(User user);
    }

}

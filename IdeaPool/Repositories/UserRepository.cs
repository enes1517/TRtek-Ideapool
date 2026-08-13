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
    public class UserRepository : RepositoryBase<User>, IUserRepository
    {
        public UserRepository(RepositoryContext context) : base(context) { }
        public async Task<List<User>> GetAllUsersAsync(bool trackChanges) =>
            await FindAll(trackChanges).ToListAsync();
        
        public async Task<User?> GetUserByIdAsync(int id, bool trackChanges) =>
            await FindByCondition(u => u.Id == id, trackChanges).SingleOrDefaultAsync();

        public async Task<User?> GetUserWithFavoritesAsync(int id, bool trackChanges) =>
            await FindByCondition(u => u.Id == id, trackChanges)
                .Include(u => u.FavoriteIdeas)
                    .ThenInclude(idea => idea.User) // Fikri paylaşan kullanıcıyı dahil ediyoruz
                .Include(u => u.FavoriteIdeas)
                    .ThenInclude(idea => idea.Evaluation) // Değerlendirme sonucunu dahil ediyoruz
                .SingleOrDefaultAsync();

        public void CreateOneUser(User user) => Create(user);
        public void UpdateOneUser(User user) => Update(user);

        public async Task<User?> GetUserByEmailAsync(string email, bool trackChanges)
        {
          return  await FindByCondition(e=>e.Email.Equals(email), trackChanges).SingleOrDefaultAsync();
        }
    }

}

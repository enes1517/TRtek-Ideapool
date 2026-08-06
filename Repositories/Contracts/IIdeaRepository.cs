using Entities.Enums;
using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories.Contracts
{
    public interface IIdeaRepository : IRepositoryBase<Idea>
    {
        Task<List<Idea>> GetAllIdeasAsync(bool trackChanges);
        Task<List<Idea>> GetFilteredIdeasAsync(string? title, IdeaCategory? category, DateTime? startDate, int? userId, bool trackChanges);
        Task<Idea?> GetIdeaByIdAsync(int id, bool trackChanges);
        void CreateOneIdea(Idea idea);
        void UpdateOneIdea(Idea idea);
        void DeleteOneIdea(Idea idea);
    }

}

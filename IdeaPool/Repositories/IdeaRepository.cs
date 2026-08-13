using Entities.Enums;
using Entities.Models;
using Entities.RequestFeatures;
using Microsoft.EntityFrameworkCore;
using Repositories.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories
{
    public class IdeaRepository : RepositoryBase<Idea>, IIdeaRepository
    {
        public IdeaRepository(RepositoryContext context) : base(context) { }

        public async Task<List<Idea>> GetAllIdeasAsync(bool trackChanges) =>
            await FindAll(trackChanges)
                .Include(i => i.User)
                .Include(i => i.Evaluation)
                    .ThenInclude(e => e.EvaluatorUser)
                .OrderByDescending(i => i.CreatedAt)
                .ToListAsync();

        public async Task<PagedList<Idea>> GetFilteredIdeasAsync(string? title, IdeaCategory? category, DateTime? startDate, int? userId, IdeaParameters ideaParameters, bool trackChanges)
        {
            var query = FindAll(trackChanges)
                .Include(i => i.User)
                .Include(i => i.Evaluation)
                    .ThenInclude(e => e.EvaluatorUser)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(title))
                query = query.Where(i => i.Title.ToLower().Contains(title.ToLower()));
            if (category.HasValue)
                query = query.Where(i => i.Category == category.Value);
            if (startDate.HasValue)
                query = query.Where(i => i.CreatedAt >= startDate.Value);
            if (userId.HasValue)
                query = query.Where(i => i.UserId == userId.Value);

            var ideas = await query
                .OrderByDescending(i => i.CreatedAt)
                .Skip((ideaParameters.PageNumber - 1) * ideaParameters.PageSize)
                .Take(ideaParameters.PageSize)
                .ToListAsync();

            var count = await query.CountAsync();
            return new PagedList<Idea>(ideas, count, ideaParameters.PageNumber, ideaParameters.PageSize);
        }



        public async Task<Idea?> GetIdeaByIdAsync(int id, bool trackChanges) =>
            await FindByCondition(i => i.Id == id, trackChanges)
                .Include(i => i.User)
                .Include(i => i.Evaluation)
                    .ThenInclude(e => e.EvaluatorUser)
                .SingleOrDefaultAsync();

        public void CreateOneIdea(Idea idea) => Create(idea);
        public void UpdateOneIdea(Idea idea) => Update(idea);
        public void DeleteOneIdea(Idea idea) => Delete(idea);
    }

}


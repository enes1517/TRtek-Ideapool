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
    public class EvaluationRepository : RepositoryBase<IdeaEvaluation>, IEvaluationRepository
    {
        public EvaluationRepository(RepositoryContext context) : base(context) { }

        public async Task<IdeaEvaluation?> GetEvaluationByIdeaIdAsync(int ideaId, bool trackChanges) =>
            await FindByCondition(e => e.IdeaId == ideaId, trackChanges)
                .Include(e => e.EvaluatorUser)
                .SingleOrDefaultAsync();

        public async Task<List<IdeaEvaluation>> GetEvaluationsByEvaluatorAsync(int evaluatorUserId, bool trackChanges) =>
            await FindByCondition(e => e.EvaluatorUserId == evaluatorUserId, trackChanges)
                .Include(e => e.Idea)
                .OrderByDescending(e => e.EvaluatedAt)
                .ToListAsync();

        public void CreateEvaluation(IdeaEvaluation evaluation) => Create(evaluation);
        public void UpdateEvaluation(IdeaEvaluation evaluation) => Update(evaluation);
        public void DeleteEvaluation(IdeaEvaluation evaluation) => Delete(evaluation);
    }
}

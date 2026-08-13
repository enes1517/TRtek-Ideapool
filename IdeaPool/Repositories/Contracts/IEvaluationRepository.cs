using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories.Contracts
{
    public interface IEvaluationRepository : IRepositoryBase<IdeaEvaluation>
    {
        Task<IdeaEvaluation?> GetEvaluationByIdeaIdAsync(int ideaId, bool trackChanges);
        Task<List<IdeaEvaluation>> GetEvaluationsByEvaluatorAsync(int evaluatorUserId, bool trackChanges);
        void CreateEvaluation(IdeaEvaluation evaluation);
        void UpdateEvaluation(IdeaEvaluation evaluation);
        void DeleteEvaluation(IdeaEvaluation evaluation);
    }
}

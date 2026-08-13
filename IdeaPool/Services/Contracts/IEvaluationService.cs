using Entities.Dtos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services.Contracts
{
    public interface IEvaluationService
    {
        Task<IdeaEvaluationResponseDto?> GetEvaluationByIdeaIdAsync(int ideaId);
        Task<List<IdeaEvaluationResponseDto>> GetEvaluationsByEvaluatorAsync(int evaluatorUserId);
        Task<IdeaEvaluationResponseDto> CreateEvaluationAsync(int evaluatorUserId, IdeaEvaluationDto dto);
        Task UpdateEvaluationAsync(int evaluationId, int evaluatorUserId, IdeaEvaluationDto dto);
    }

}

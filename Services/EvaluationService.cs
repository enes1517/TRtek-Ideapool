using AutoMapper;
using Entities.Dtos;
using Entities.Enums;
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
    public class EvaluationService : IEvaluationService
    {
        private readonly IRepositoryManager _repo;
        private readonly IMapper _mapper;

        public EvaluationService(IRepositoryManager repo, IMapper mapper)
        {
            _repo = repo;
            _mapper = mapper;
        }

        public async Task<IdeaEvaluationResponseDto?> GetEvaluationByIdeaIdAsync(int ideaId)
        {
            var eval = await _repo.Evaluation.GetEvaluationByIdeaIdAsync(ideaId, trackChanges: false);
            return _mapper.Map<IdeaEvaluationResponseDto?>(eval);
        }

        public async Task<List<IdeaEvaluationResponseDto>> GetEvaluationsByEvaluatorAsync(int evaluatorUserId)
        {
            var evals = await _repo.Evaluation.GetEvaluationsByEvaluatorAsync(evaluatorUserId, trackChanges: false);
            return _mapper.Map<List<IdeaEvaluationResponseDto>>(evals);
        }

        public async Task<IdeaEvaluationResponseDto> CreateEvaluationAsync(int evaluatorUserId, IdeaEvaluationDto dto)
        {
            // 1. Fikir var mı?
            var idea = await _repo.Idea.GetIdeaByIdAsync(dto.IdeaId, trackChanges: true)
                ?? throw new Exception($"Id={dto.IdeaId} fikir bulunamadı.");

            // 2. Zaten değerlendirilmiş mi?
            var existing = await _repo.Evaluation.GetEvaluationByIdeaIdAsync(dto.IdeaId, trackChanges: false);
            if (existing != null)
                throw new Exception("Bu fikir zaten değerlendirilmiş.");

            // 3. Score kontrolü
            if (dto.Score is < 1 or > 100)
                throw new Exception("Puan 1 ile 100 arasında olmalıdır.");

            // DTO -> Entity Dönüşümü
            var evaluation = _mapper.Map<IdeaEvaluation>(dto);
            evaluation.EvaluatorUserId = evaluatorUserId;

            _repo.Evaluation.CreateEvaluation(evaluation);

            // 4. Fikrin durumunu otomatik güncelle
            idea.Status = dto.IsApproved ? IdeaStatus.Olumlu : IdeaStatus.Olumsuz;
            _repo.Idea.UpdateOneIdea(idea);

            await _repo.SaveAsync();

            var created = await _repo.Evaluation.GetEvaluationByIdeaIdAsync(dto.IdeaId, trackChanges: false);
            return _mapper.Map<IdeaEvaluationResponseDto>(created!);
        }

        public async Task UpdateEvaluationAsync(int evaluationId, int evaluatorUserId, IdeaEvaluationDto dto)
        {
            var eval = await _repo.Evaluation.GetEvaluationByIdeaIdAsync(dto.IdeaId, trackChanges: true)
                ?? throw new Exception("Değerlendirme bulunamadı.");

            if (eval.EvaluatorUserId != evaluatorUserId)
                throw new UnauthorizedAccessException("Bu değerlendirmeyi düzenleme yetkiniz yok.");

            if (dto.Score is < 1 or > 100)
                throw new Exception("Puan 1 ile 100 arasında olmalıdır.");

            // DTO içerisindeki değerleri mevcut entity üzerine kopyalar
            _mapper.Map(dto, eval);

            _repo.Evaluation.UpdateEvaluation(eval);

            // Fikrin durumunu da güncelle
            var idea = await _repo.Idea.GetIdeaByIdAsync(dto.IdeaId, trackChanges: true);
            if (idea != null)
            {
                idea.Status = dto.IsApproved ? IdeaStatus.Olumlu : IdeaStatus.Olumsuz;
                _repo.Idea.UpdateOneIdea(idea);
            }

            await _repo.SaveAsync();
        }
    }

}

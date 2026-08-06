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
    public class IdeaService : IIdeaService
    {
        private readonly IRepositoryManager _repo;
        private readonly IMapper _mapper;

        public IdeaService(IRepositoryManager repo, IMapper mapper)
        {
            _repo = repo;
            _mapper = mapper;
        }

        public async Task<List<IdeaResponseDto>> GetAllIdeasAsync()
        {
            var ideas = await _repo.Idea.GetAllIdeasAsync(trackChanges: false);
            return _mapper.Map<List<IdeaResponseDto>>(ideas);
        }

        public async Task<List<IdeaResponseDto>> GetFilteredIdeasAsync(
            string? title, IdeaCategory? category, DateTime? startDate, int? userId)
        {
            var ideas = await _repo.Idea.GetFilteredIdeasAsync(title, category, startDate, userId, trackChanges: false);
            return _mapper.Map<List<IdeaResponseDto>>(ideas);
        }

        public async Task<IdeaResponseDto> GetIdeaByIdAsync(int id)
        {
            var idea = await _repo.Idea.GetIdeaByIdAsync(id, trackChanges: false)
                ?? throw new Exception($"Id={id} fikir bulunamadı.");

            return _mapper.Map<IdeaResponseDto>(idea);
        }

        public async Task<IdeaResponseDto> CreateIdeaAsync(int userId, CreateIdeaDto dto)
        {
            var idea = _mapper.Map<Idea>(dto);
            idea.UserId = userId;
            idea.Status = IdeaStatus.Beklemede;

            _repo.Idea.CreateOneIdea(idea);
            await _repo.SaveAsync();

            // İlişkili nesnelerle (User, Evaluation) birlikte tam DTO dönmek için DB'den çekiyoruz
            var created = await _repo.Idea.GetIdeaByIdAsync(idea.Id, trackChanges: false);
            return _mapper.Map<IdeaResponseDto>(created!);
        }

        public async Task UpdateIdeaAsync(int id, int userId, CreateIdeaDto dto)
        {
            var idea = await _repo.Idea.GetIdeaByIdAsync(id, trackChanges: true)
                ?? throw new Exception($"Id={id} fikir bulunamadı.");

            if (idea.UserId != userId)
                throw new UnauthorizedAccessException("Bu fikri düzenleme yetkiniz yok.");

            // DTO üzerindeki değişiklikleri mevcut entity nesnesine aktarır
            _mapper.Map(dto, idea);

            _repo.Idea.UpdateOneIdea(idea);
            await _repo.SaveAsync();
        }

        public async Task DeleteIdeaAsync(int id, int userId)
        {
            var idea = await _repo.Idea.GetIdeaByIdAsync(id, trackChanges: true)
                ?? throw new Exception($"Id={id} fikir bulunamadı.");

            if (idea.UserId != userId)
                throw new UnauthorizedAccessException("Bu fikri silme yetkiniz yok.");

            _repo.Idea.DeleteOneIdea(idea);
            await _repo.SaveAsync();
        }
    }

}

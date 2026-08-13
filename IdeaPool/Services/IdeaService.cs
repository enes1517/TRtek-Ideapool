using AutoMapper;
using Entities.Dtos;
using Entities.Enums;
using Entities.Models;
using Entities.RequestFeatures;
using Repositories.Contracts;
using Services.Contracts;
using Services.Infrastructure.Exceptions;

namespace Services
{
    public class IdeaService(IRepositoryManager repo, IMapper mapper) : IIdeaService
    {
        private readonly IRepositoryManager _repo = repo;
        private readonly IMapper _mapper = mapper;

        public async Task<List<IdeaResponseDto>> GetAllIdeasAsync()
        {
            var ideas = await _repo.Idea.GetAllIdeasAsync(trackChanges: false);
            return _mapper.Map<List<IdeaResponseDto>>(ideas);
        }

        public async Task<(List<IdeaResponseDto> ideas, MetaData metaData)> GetFilteredIdeasAsync(
     string? title, IdeaCategory? category, DateTime? startDate, int? userId,IdeaParameters ideaParameters)
        {
            var pagedIdeas = await _repo.Idea.GetFilteredIdeasAsync(title, category, startDate, userId, ideaParameters, trackChanges: false);

            // AutoMapper ile PagedList içindeki verileri DTO listesine çeviriyoruz
            var ideasDto = _mapper.Map<List<IdeaResponseDto>>(pagedIdeas);

            return (ideasDto, pagedIdeas.MetaData);
        }



        public async Task<IdeaResponseDto> GetIdeaByIdAsync(int id)
        {
            var idea = await _repo.Idea.GetIdeaByIdAsync(id, trackChanges: false)
                ?? throw new NotFoundException($"Id={id} olan fikir bulunamadı.");

            return _mapper.Map<IdeaResponseDto>(idea);
        }

        public async Task<IdeaResponseDto> CreateIdeaAsync(int userId, CreateIdeaDto dto)
        {
            // AutoMapper DTO içindeki DocumentUrl dahil tüm alanları otomatik eşler
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
                ?? throw new NotFoundException($"Id={id} olan fikir bulunamadı.");

            if (idea.UserId != userId)
                throw new UnauthorizedAccessException("Bu fikri düzenleme yetkiniz yok.");

            // DTO üzerindeki yeni verileri (Title, Description, DocumentUrl vb.) mevcut entity üzerine aktarır
            _mapper.Map(dto, idea);

            _repo.Idea.UpdateOneIdea(idea);
            await _repo.SaveAsync();
        }

        public async Task DeleteIdeaAsync(int id, int userId)
        {
            var idea = await _repo.Idea.GetIdeaByIdAsync(id, trackChanges: true)
                ?? throw new NotFoundException($"Id={id} olan fikir bulunamadı.");

            if (idea.UserId != userId)
                throw new UnauthorizedAccessException("Bu fikri silme yetkiniz yok.");

            _repo.Idea.DeleteOneIdea(idea);
            await _repo.SaveAsync();
        }

        public async Task ToggleFavoriteAsync(int userId, int ideaId)
        {
            var user = await _repo.User.GetUserWithFavoritesAsync(userId, trackChanges: true)
                ?? throw new NotFoundException($"Id={userId} olan kullanıcı bulunamadı.");

            var idea = await _repo.Idea.GetIdeaByIdAsync(ideaId, trackChanges: true)
                ?? throw new NotFoundException($"Id={ideaId} olan fikir bulunamadı.");

            var isFavorite = user.FavoriteIdeas.Any(i => i.Id == ideaId);
            if (isFavorite)
            {
                user.FavoriteIdeas.Remove(idea);
            }
            else
            {
                user.FavoriteIdeas.Add(idea);
            }

            await _repo.SaveAsync();
        }

        public async Task<List<IdeaResponseDto>> GetFavoriteIdeasAsync(int userId)
        {
            var user = await _repo.User.GetUserWithFavoritesAsync(userId, trackChanges: false)
                ?? throw new NotFoundException($"Id={userId} olan kullanıcı bulunamadı.");

            return _mapper.Map<List<IdeaResponseDto>>(user.FavoriteIdeas);
        }
    }
}
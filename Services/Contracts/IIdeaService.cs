using Entities.Dtos;
using Entities.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services.Contracts
{
    public interface IIdeaService
    {
        Task<List<IdeaResponseDto>> GetAllIdeasAsync();
        Task<List<IdeaResponseDto>> GetFilteredIdeasAsync(
            string? title, IdeaCategory? category, DateTime? startDate, int? userId);
        Task<IdeaResponseDto> GetIdeaByIdAsync(int id);
        Task<IdeaResponseDto> CreateIdeaAsync(int userId, CreateIdeaDto dto);
        Task UpdateIdeaAsync(int id, int userId, CreateIdeaDto dto);
        Task DeleteIdeaAsync(int id, int userId);
    }

}

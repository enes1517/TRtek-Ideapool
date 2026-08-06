using Entities.Dtos;
using Entities.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Services.Contracts;

namespace IdeaPool.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class IdeaController : ControllerBase
    {
        private readonly IIdeaService _ideaService;
        public IdeaController(IIdeaService ideaService) => _ideaService = ideaService;
        // Token'dan userId oku
        private int GetUserId() =>
            int.Parse(User.FindFirst("userId")?.Value ?? "0");
        [HttpGet]
        public async Task<IActionResult> GetAll(
            [FromQuery] string? title,
            [FromQuery] IdeaCategory? category,
            [FromQuery] DateTime? startDate,
            [FromQuery] int? userId)
        {
            var ideas = await _ideaService.GetFilteredIdeasAsync(title, category, startDate, userId);
            return Ok(ideas);
        }
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var idea = await _ideaService.GetIdeaByIdAsync(id);
            return Ok(idea);
        }
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Create([FromBody] CreateIdeaDto dto)
        {
            var result = await _ideaService.CreateIdeaAsync(GetUserId(), dto);
            return Created($"api/ideas/{result.Id}", result);
        }
        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> Update(int id, [FromBody] CreateIdeaDto dto)
        {
            await _ideaService.UpdateIdeaAsync(id, GetUserId(), dto);
            return NoContent();
        }
        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> Delete(int id)
        {
            await _ideaService.DeleteIdeaAsync(id, GetUserId());
            return NoContent();
        }
    }

}

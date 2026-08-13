using Entities.Dtos;
using Entities.Enums;
using Entities.RequestFeatures;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Services.Contracts;
using System.Text.Json;

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
    [FromQuery] int? userId,
    [FromQuery] IdeaParameters ideaParameters)
        {
            var pagedResult = await _ideaService.GetFilteredIdeasAsync(title, category, startDate, userId, ideaParameters);

            Response.Headers["X-Pagination"] = JsonSerializer.Serialize(pagedResult.metaData);

            return Ok(pagedResult.ideas);

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

        [HttpPost("upload")]
        [Authorize]
        public async Task<IActionResult> UploadDocument(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("Geçersiz dosya.");

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            var uniqueFileName = Guid.NewGuid().ToString() + "_" + file.FileName;
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(fileStream);
            }

            var documentUrl = $"/uploads/{uniqueFileName}";
            return Ok(new { url = documentUrl });
        }

        [HttpPost("{id}/favorite")]
        [Authorize]
        public async Task<IActionResult> ToggleFavorite(int id)
        {
            await _ideaService.ToggleFavoriteAsync(GetUserId(), id);
            return NoContent();
        }

        [HttpGet("favorites")]
        [Authorize]
        public async Task<IActionResult> GetFavorites()
        {
            var favorites = await _ideaService.GetFavoriteIdeasAsync(GetUserId());
            return Ok(favorites);
        }
    }

}

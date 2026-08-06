using Entities.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Services.Contracts;

namespace IdeaPool.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Route("api/evaluations")]
    public class EvaluationController : ControllerBase
    {
        private readonly IEvaluationService _evalService;
        public EvaluationController(IEvaluationService evalService) => _evalService = evalService;

        private int GetUserId() =>
            int.Parse(User.FindFirst("userId")?.Value ?? "0");

        [HttpGet("idea/{ideaId}")]
        public async Task<IActionResult> GetByIdea(int ideaId)
        {
            var result = await _evalService.GetEvaluationByIdeaIdAsync(ideaId);
            return result != null ? Ok(result) : NotFound();
        }

        [HttpGet("by-me")]
        [Authorize]
        public async Task<IActionResult> GetByMe()
        {
            var result = await _evalService.GetEvaluationsByEvaluatorAsync(GetUserId());
            return Ok(result);
        }

        [HttpPost]
        [Authorize(Policy = "FikirDegerlendirme")]
        public async Task<IActionResult> Create([FromBody] IdeaEvaluationDto dto)
        {
            var result = await _evalService.CreateEvaluationAsync(GetUserId(), dto);
            return Created("", result);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "FikirDegerlendirme")]
        public async Task<IActionResult> Update(int id, [FromBody] IdeaEvaluationDto dto)
        {
            await _evalService.UpdateEvaluationAsync(id, GetUserId(), dto);
            return NoContent();
        }
    }

}

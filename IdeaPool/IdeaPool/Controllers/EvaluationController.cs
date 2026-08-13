using Entities.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Services.Contracts;

namespace IdeaPool.Controllers
{
    [ApiController]
    [Route("api/evaluations")]
    public class EvaluationController : ControllerBase
    {
        private readonly IEvaluationService _evalService;
        private readonly IPermissionService _permService;
        
        public EvaluationController(IEvaluationService evalService, IPermissionService permService)
        {
            _evalService = evalService;
            _permService = permService;
        }

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
        [Authorize]
        public async Task<IActionResult> Create([FromBody] IdeaEvaluationDto dto)
        {
            var userId = GetUserId();
            var livePerms = await _permService.GetUserPermissionsAsync(userId);
            if (!livePerms.Any(p => p.Code == "FikirDegerlendirme")) return Forbid();

            var result = await _evalService.CreateEvaluationAsync(userId, dto);
            return Created("", result);
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> Update(int id, [FromBody] IdeaEvaluationDto dto)
        {
            var userId = GetUserId();
            var livePerms = await _permService.GetUserPermissionsAsync(userId);
            if (!livePerms.Any(p => p.Code == "FikirDegerlendirme")) return Forbid();

            await _evalService.UpdateEvaluationAsync(id, userId, dto);
            return NoContent();
        }
    }

}

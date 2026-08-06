using Entities.Dtos;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Services.Contracts;

namespace IdeaPool.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PermissionController : ControllerBase
    {
        private readonly IPermissionService _permService;
        public PermissionController(IPermissionService permService) => _permService = permService;
        [HttpGet]
        public async Task<IActionResult> GetAll() =>
            Ok(await _permService.GetAllPermissionsAsync());
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserPermissions(int userId) =>
            Ok(await _permService.GetUserPermissionsAsync(userId));
        [HttpPost("grant")]
        [Authorize(Policy = "KullaniciYetkiEkleme")]
        public async Task<IActionResult> Grant([FromBody] GrantRevokeDto dto)
        {
            await _permService.GrantPermissionAsync(dto.UserId, dto.PermissionId);
            return NoContent();
        }
        [HttpDelete("revoke")]
        [Authorize(Policy = "KullaniciYetkiSilme")]
        public async Task<IActionResult> Revoke([FromBody] GrantRevokeDto dto)
        {
            await _permService.RevokePermissionAsync(dto.UserId, dto.PermissionId);
            return NoContent();
        }
    }


}

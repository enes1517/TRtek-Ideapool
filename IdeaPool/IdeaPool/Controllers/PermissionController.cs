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
        [Authorize]
        public async Task<IActionResult> Grant([FromBody] GrantRevokeDto dto)
        {
            var userIdClaim = User.FindFirst("userId")?.Value;
            if (userIdClaim == null || !int.TryParse(userIdClaim, out int currentUserId)) return Unauthorized();
            
            var livePerms = await _permService.GetUserPermissionsAsync(currentUserId);
            if (!livePerms.Any(p => p.Code == "KullaniciYetkiEkleme")) return Forbid();

            // Sadece yetki yoksa ekle (Unique Constraint Exception'ı önlemek için)
            var targetUserPerms = await _permService.GetUserPermissionsAsync(dto.UserId);
            if (!targetUserPerms.Any(p => p.Id == dto.PermissionId))
            {
                await _permService.GrantPermissionAsync(dto.UserId, dto.PermissionId);
            }
            
            return NoContent();
        }
        [HttpDelete("revoke/{userId}/{permissionId}")]
        [Authorize]
        public async Task<IActionResult> Revoke(int userId, int permissionId)
        {
            var userIdClaim = User.FindFirst("userId")?.Value;
            if (userIdClaim == null || !int.TryParse(userIdClaim, out int currentUserId)) return Unauthorized();
            
            var livePerms = await _permService.GetUserPermissionsAsync(currentUserId);
            if (!livePerms.Any(p => p.Code == "KullaniciYetkiSilme")) return Forbid();

            await _permService.RevokePermissionAsync(userId, permissionId);
            return NoContent();
        }
    }


}

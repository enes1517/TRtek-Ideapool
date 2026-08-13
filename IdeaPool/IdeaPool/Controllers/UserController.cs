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
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IPermissionService _permService;
        public UserController(IUserService userService, IPermissionService permService)
        {
            _userService = userService;
            _permService = permService;
        }
        [HttpGet]
        public async Task<IActionResult> GetAll() => Ok(await _userService.GetAllUsersAsync());
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id) => Ok(await _userService.GetUserByIdAsync(id));
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateUserDto dto)
        {
            var userIdClaim = User.FindFirst("userId")?.Value;
            if (userIdClaim == null || !int.TryParse(userIdClaim, out int currentUserId)) return Unauthorized();
            
            var livePerms = await _permService.GetUserPermissionsAsync(currentUserId);
            if (!livePerms.Any(p => p.Code == "KullaniciYetkiEkleme")) return Forbid();

            await _userService.UpdateUserAsync(id, dto);
            return NoContent();
        }
        [HttpPatch("{id}/toggle-status")]
        [Authorize] 
        public async Task<IActionResult> ToggleStatus(int id)
        {
            var userIdClaim = User.FindFirst("userId")?.Value;
            if (userIdClaim == null || !int.TryParse(userIdClaim, out int currentUserId)) return Unauthorized();
            
            var livePerms = await _permService.GetUserPermissionsAsync(currentUserId);
            if (!livePerms.Any(p => p.Code == "KullaniciYetkiEkleme")) return Forbid();

            await _userService.ToggleUserStatusAsync(id);
            return NoContent();
        }

        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto dto)
        {
            var userIdClaim = User.FindFirst("userId")?.Value;
            if (userIdClaim == null || !int.TryParse(userIdClaim, out int currentUserId)) return Unauthorized();

            await _userService.ChangePasswordAsync(currentUserId, dto);
            return NoContent();
        }

        [HttpPatch("avatar")]
        public async Task<IActionResult> UpdateAvatar([FromBody] UpdateAvatarDto dto)
        {
            var userIdClaim = User.FindFirst("userId")?.Value;
            if (userIdClaim == null || !int.TryParse(userIdClaim, out int currentUserId)) return Unauthorized();

            await _userService.UpdateAvatarAsync(currentUserId, dto.AvatarUrl);
            return NoContent();
        }
    }


}

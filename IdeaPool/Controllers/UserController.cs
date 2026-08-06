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
        public UserController(IUserService userService) => _userService = userService;
        [HttpGet]
        public async Task<IActionResult> GetAll() => Ok(await _userService.GetAllUsersAsync());
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id) => Ok(await _userService.GetUserByIdAsync(id));
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateUserDto dto)
        {
            await _userService.UpdateUserAsync(id, dto);
            return NoContent();
        }
        // YENİ: PDF gereksinimi olan kullanıcı pasife alma işlemi
        [HttpPatch("{id}/deactivate")]
        [Authorize(Policy = "KullaniciYetkiSilme")] 
        public async Task<IActionResult> Deactivate(int id)
        {
            await _userService.DeactivateUserAsync(id);
            return NoContent();
        }
    }


}

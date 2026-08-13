using Entities.Dtos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Services.Contracts
{
    public interface IUserService
    {
        Task<UserResponseDto> RegisterAsync(CreateUserDto dto);
        Task<LoginResponseDto> LoginAsync(LoginDto dto);
        Task<List<UserResponseDto>> GetAllUsersAsync();
        Task<UserResponseDto> GetUserByIdAsync(int id);
        Task UpdateUserAsync(int id, UpdateUserDto dto);
        Task ToggleUserStatusAsync(int id);
        Task ChangePasswordAsync(int userId, ChangePasswordDto dto);
        Task UpdateAvatarAsync(int userId, string avatarUrl);
        Task<GoogleAuthResultDto> GoogleLoginAsync(GoogleLoginDto dto);
        Task<LoginResponseDto> GoogleRegisterAsync(GoogleRegisterDto dto);

    }

}

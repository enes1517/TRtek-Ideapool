using AutoMapper;
using Entities.Dtos;
using Entities.Models;
using Repositories.Contracts;
using Services.Contracts;
using Services.Infrastructure.Exceptions;
using Services.Infrastructure.Security;

namespace Services
{
    public class UserService(
        IRepositoryManager repo,
        IJwtService jwt,
        IMapper mapper) : IUserService
    {
        private readonly IRepositoryManager _repo = repo;
        private readonly IJwtService _jwt = jwt;
        private readonly IMapper _mapper = mapper;

        public async Task<UserResponseDto> RegisterAsync(CreateUserDto dto)
        {
            var existingUser = await _repo.User.GetUserByEmailAsync(dto.Email, trackChanges: false);
            if (existingUser != null)
                throw new BadRequestException("Bu e-posta adresi zaten kullanımda.");

            // 1. DTO -> Entity Dönüşümü (AutoMapper)
            var user = _mapper.Map<User>(dto);

            // 2. Özel İş Mantığı & Güvenlik Alanları (Manual Assign)
            PasswordHasher.CreatePasswordHash(dto.Password, out byte[] hash, out byte[] salt);
            user.PasswordHash = hash;
            user.PasswordSalt = salt;
            user.IsActive = true; // Yeni kayıtta varsayılan durum

            _repo.User.CreateOneUser(user);
            await _repo.SaveAsync();

            // 3. Entity -> Response DTO Dönüşümü (AutoMapper)
            return _mapper.Map<UserResponseDto>(user);
        }

        public async Task<LoginResponseDto> LoginAsync(LoginDto dto)
        {
            var user = await _repo.User.GetUserByEmailAsync(dto.Email, trackChanges: false)
                ?? throw new NotFoundException("Kullanıcı veya şifre hatalı.");

            if (!user.IsActive)
                throw new UnauthorizedException("Hesabınız pasif durumdadır. Lütfen yöneticinizle iletişime geçin.");

            if (!PasswordHasher.VerifyPasswordHash(dto.Password, user.PasswordHash, user.PasswordSalt))
                throw new UnauthorizedException("Kullanıcı veya şifre hatalı.");

            var permissions = await _repo.Permission.GetUserPermissionsAsync(user.Id, trackChanges: false);
            var permCodes = permissions.Select(p => p.Code).ToList();

            var token = _jwt.GenerateToken(user, permCodes);

            return new LoginResponseDto
            {
                Token = token,
                User = _mapper.Map<UserResponseDto>(user), // AutoMapper
                Permissions = permCodes
            };
        }

        public async Task<List<UserResponseDto>> GetAllUsersAsync()
        {
            var users = await _repo.User.GetAllUsersAsync(trackChanges: false);

            // IEnumerable/List dönüşümleri için AutoMapper
            return _mapper.Map<List<UserResponseDto>>(users);
        }

        public async Task<UserResponseDto> GetUserByIdAsync(int id)
        {
            var user = await _repo.User.GetUserByIdAsync(id, trackChanges: false)
                ?? throw new NotFoundException($"Id={id} olan kullanıcı bulunamadı.");

            return _mapper.Map<UserResponseDto>(user);
        }

        public async Task UpdateUserAsync(int id, UpdateUserDto dto)
        {
            var user = await _repo.User.GetUserByIdAsync(id, trackChanges: true)
                ?? throw new NotFoundException($"Id={id} olan kullanıcı bulunamadı.");

            // DTO -> Existing Entity (Mevcut EF Core takip nesnesi üzerine yansıtma)
            _mapper.Map(dto, user);

            _repo.User.UpdateOneUser(user);
            await _repo.SaveAsync();
        }
    }
}

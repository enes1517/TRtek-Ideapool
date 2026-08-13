using AutoMapper;
using Entities.Dtos;
using Entities.Models;
using Google.Apis.Auth;
using Repositories.Contracts;
using Services.Contracts;
using Services.Infrastructure.Exceptions;
using Services.Infrastructure.Security;
using Microsoft.Extensions.Configuration;

namespace Services
{
    public class UserService(
        IRepositoryManager repo,
        IJwtService jwt,
        IConfiguration config,
        IMapper mapper) : IUserService
    {
        private readonly IRepositoryManager _repo = repo;
        private readonly IJwtService _jwt = jwt;
        private readonly IConfiguration _config = config;
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

        public async Task<GoogleAuthResultDto> GoogleLoginAsync(GoogleLoginDto dto)
        {
            GoogleJsonWebSignature.Payload payload;

            if (dto.IdToken.StartsWith("ya29.")) // Web Access Token Fallback
            {
                using var client = new HttpClient();
                var response = await client.GetAsync($"https://www.googleapis.com/oauth2/v3/userinfo?access_token={dto.IdToken}");
                if (!response.IsSuccessStatusCode) throw new Exception("Geçersiz Google Access Token'ı.");
                
                var json = await response.Content.ReadAsStringAsync();
                var doc = System.Text.Json.JsonDocument.Parse(json);
                payload = new GoogleJsonWebSignature.Payload
                {
                    Email = doc.RootElement.GetProperty("email").GetString(),
                    GivenName = doc.RootElement.TryGetProperty("given_name", out var gn) ? gn.GetString() : "Google",
                    FamilyName = doc.RootElement.TryGetProperty("family_name", out var fn) ? fn.GetString() : "Kullanıcısı"
                };
            }
            else
            {
                var settings = new GoogleJsonWebSignature.ValidationSettings()
                {
                    Audience = new List<string> { _config["Authentication:Google:ClientId"] }
                };

                payload = await GoogleJsonWebSignature.ValidateAsync(dto.IdToken, settings)
                    ?? throw new Exception("Geçersiz Google Token'ı.");
            }

            var user = await _repo.User.GetUserByEmailAsync(payload.Email, false);

            // KULLANICI YOKSA: Kayıt formu için Frontend'i bilgilendir
            if (user == null)
            {
                return new GoogleAuthResultDto
                {
                    RequiresRegistration = true,
                    Email = payload.Email,
                    FirstName = payload.GivenName ?? "Google",
                    LastName = payload.FamilyName ?? "Kullanıcısı"
                };
            }

            // KULLANICI VARSA: Standart JWT üret ve giriş yap
            if (!user.IsActive) throw new Exception("Hesabınız pasif durumdadır.");

            var permissions = await _repo.Permission.GetUserPermissionsAsync(user.Id, false);
            var permCodes = permissions.Select(p => p.Code).ToList();
            var token = _jwt.GenerateToken(user, permCodes);

            return new GoogleAuthResultDto
            {
                RequiresRegistration = false,
                LoginResponse = new LoginResponseDto
                {
                    Token = token,
                    User = _mapper.Map<UserResponseDto>(user), // AutoMapper
                    Permissions = permCodes
                }
            };
        }

        public async Task<LoginResponseDto> GoogleRegisterAsync(GoogleRegisterDto dto)
        {
            GoogleJsonWebSignature.Payload payload;

            if (dto.IdToken.StartsWith("ya29.")) // Web Access Token Fallback
            {
                using var client = new HttpClient();
                var response = await client.GetAsync($"https://www.googleapis.com/oauth2/v3/userinfo?access_token={dto.IdToken}");
                if (!response.IsSuccessStatusCode) throw new Exception("Geçersiz Google Access Token'ı.");
                
                var json = await response.Content.ReadAsStringAsync();
                var doc = System.Text.Json.JsonDocument.Parse(json);
                payload = new GoogleJsonWebSignature.Payload
                {
                    Email = doc.RootElement.GetProperty("email").GetString(),
                    GivenName = doc.RootElement.TryGetProperty("given_name", out var gn) ? gn.GetString() : "Google",
                    FamilyName = doc.RootElement.TryGetProperty("family_name", out var fn) ? fn.GetString() : "Kullanıcısı"
                };
            }
            else
            {
                var settings = new GoogleJsonWebSignature.ValidationSettings()
                {
                    Audience = new List<string> { _config["Authentication:Google:ClientId"] }
                };

                payload = await GoogleJsonWebSignature.ValidateAsync(dto.IdToken, settings)
                    ?? throw new Exception("Geçersiz Google Token'ı.");
            }

            var user = await _repo.User.GetUserByEmailAsync(payload.Email, false);
            if (user != null) throw new Exception("Bu e-posta adresi zaten kullanımda. Lütfen direkt giriş yapın.");

            // 1. AutoMapper ile Phone, IdentityNumber, RegistrationNumber vb. alanları aktar
            var newUser = _mapper.Map<User>(dto);

            // 2. Google Payload'ından ve güvenlik adımlarından gelen özel alanları doldur
            newUser.FirstName = payload.GivenName ?? "Google";
            newUser.LastName = payload.FamilyName ?? "Kullanıcısı";
            newUser.Email = payload.Email;
            newUser.IsActive = true;

            // Rastgele şifre üretimi ve Hash/Salt ataması
            var randomPassword = Guid.NewGuid().ToString();
            PasswordHasher.CreatePasswordHash(randomPassword, out byte[] hash, out byte[] salt);
            newUser.PasswordHash = hash;
            newUser.PasswordSalt = salt;

            _repo.User.CreateOneUser(newUser);
            await _repo.SaveAsync();

            // Yeni kayıt olan kullanıcıya JWT oluştur
            var permissions = await _repo.Permission.GetUserPermissionsAsync(newUser.Id, false);
            var permCodes = permissions.Select(p => p.Code).ToList();
            var token = _jwt.GenerateToken(newUser, permCodes);

            return new LoginResponseDto
            {
                Token = token,
                User = _mapper.Map<UserResponseDto>(newUser), // AutoMapper
                Permissions = permCodes
            };
        }

        public async Task<LoginResponseDto> LoginAsync(LoginDto dto)
        {
            var user = await _repo.User.GetUserByEmailAsync(dto.Email, trackChanges: false)
                ?? throw new NotFoundException("Kullanıcı veya şifre hatalı.");

            if (!PasswordHasher.VerifyPasswordHash(dto.Password, user.PasswordHash, user.PasswordSalt))
                throw new UnauthorizedException("Kullanıcı veya şifre hatalı.");

            if (!user.IsActive)
                throw new UnauthorizedException("Hesabınız pasif durumdadır. Lütfen yöneticinizle iletişime geçin.");

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

        public async Task ToggleUserStatusAsync(int id)
        {
            var user = await _repo.User.GetUserByIdAsync(id, trackChanges: true)
                ?? throw new NotFoundException($"Id={id} olan kullanıcı bulunamadı.");

            user.IsActive = !user.IsActive; // Toggle

            _repo.User.UpdateOneUser(user);
            await _repo.SaveAsync();
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
        public async Task ChangePasswordAsync(int userId, ChangePasswordDto dto)
        {
            var user = await _repo.User.GetUserByIdAsync(userId, trackChanges: true)
                ?? throw new NotFoundException($"Id={userId} olan kullanıcı bulunamadı.");

            if (!PasswordHasher.VerifyPasswordHash(dto.OldPassword, user.PasswordHash, user.PasswordSalt))
                throw new UnauthorizedException("Mevcut şifre hatalı.");

            PasswordHasher.CreatePasswordHash(dto.NewPassword, out byte[] passwordHash, out byte[] passwordSalt);
            user.PasswordHash = passwordHash;
            user.PasswordSalt = passwordSalt;

            _repo.User.UpdateOneUser(user);
            await _repo.SaveAsync();
        }

        public async Task UpdateAvatarAsync(int userId, string avatarUrl)
        {
            var user = await _repo.User.GetUserByIdAsync(userId, trackChanges: true)
                ?? throw new NotFoundException($"Id={userId} olan kullanıcı bulunamadı.");

            user.AvatarUrl = avatarUrl;

            _repo.User.UpdateOneUser(user);
            await _repo.SaveAsync();
        }
    }
}

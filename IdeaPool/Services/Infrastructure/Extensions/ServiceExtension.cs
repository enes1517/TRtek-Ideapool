using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Entities.Models;
using Repositories;
using Repositories.Contracts;
using Services.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Services.Infrastructure.Security;

namespace Services.Infrastructure.Extensions
{
    public static class ServiceExtension
    {
        public static void ConfigureDbContext(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddDbContext<RepositoryContext>(options =>
            {
                options.UseNpgsql(configuration.GetConnectionString("Connection"),
                b => b.MigrationsAssembly("IdeaPool"));
            });
        }

        public static void ConfigureCors(this IServiceCollection services)
        {
            services.AddCors(options =>
            {
                options.AddPolicy("AllowAll", policy =>
                {
                    policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
                });
            });
        }

        public static void ConfigureJwt(this IServiceCollection services, IConfiguration configuration)
        {
            var jwtSettings = configuration.GetSection("JwtSettings");
            var key = Encoding.UTF8.GetBytes(jwtSettings["Secret"]!);
            services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(key),
                        ValidateIssuer = true,
                        ValidIssuer = jwtSettings["Issuer"],
                        ValidateAudience = true,
                        ValidAudience = jwtSettings["Audience"],
                        ValidateLifetime = true,
                        ClockSkew = TimeSpan.Zero
                    };
                });
        }

        public static void ConfigureAuthorization(this IServiceCollection services)
        {
            services.AddAuthorization(options =>
            {
                options.AddPolicy("FikirDegerlendirme",
                    p => p.RequireClaim("permission", "FikirDegerlendirme"));
                options.AddPolicy("KullaniciYetkiEkleme",
                    p => p.RequireClaim("permission", "KullaniciYetkiEkleme"));
                options.AddPolicy("KullaniciYetkiSilme",
                    p => p.RequireClaim("permission", "KullaniciYetkiSilme"));
            });
        }

        public static void ConfigureServices(this IServiceCollection services)
        {
            services.AddScoped<IRepositoryManager, RepositoryManager>();
            services.AddScoped<IJwtService, JwtService>();
            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IIdeaService, IdeaService>();
            services.AddScoped<IEvaluationService, EvaluationService>();
            services.AddScoped<IPermissionService, PermissionService>();
        }

        // 1. Zorunlu İzinleri Seed Eden Metot
        public static IApplicationBuilder ConfigureDatabaseSeed(this IApplicationBuilder app)
        {
            using (var scope = app.ApplicationServices.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<RepositoryContext>();
                try
                {
                    context.Database.Migrate();
                    var requiredPermissions = new[]
                    {
                        new Permission { Code = "FikirDegerlendirme", Description = "Fikir ve önerileri değerlendirme yetkisi" },
                        new Permission { Code = "KullaniciYetkiEkleme", Description = "Kullanıcılara yeni yetki tanımlama yetkisi" },
                        new Permission { Code = "KullaniciYetkiSilme", Description = "Kullanıcılardan yetki kaldırma yetkisi" }
                    };

                    var existingPermCodes = context.Permissions.Select(p => p.Code).ToHashSet();
                    var newPermissions = requiredPermissions
                        .Where(rp => !existingPermCodes.Contains(rp.Code))
                        .ToList();

                    if (newPermissions.Any())
                    {
                        context.Permissions.AddRange(newPermissions);
                        context.SaveChanges();
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"İzin seed işlemi sırasında hata: {ex.Message}");
                }
            }

            return app;
        }

        // 2. Custom User Modeli ile Default Admin Oluşturan Metot (Identity Olmadan)
        public static IApplicationBuilder ConfigureDefaultAdminUser(
            this IApplicationBuilder app,
            string adminEmail = "enesipek@gmail.com",
            string adminPassword = "Admin",
            string firstName = "Enes",
            string lastName = "İpek")
        {
            using (var scope = app.ApplicationServices.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<RepositoryContext>();
                try
                {
                    // 1. Kullanıcı Veritabanında Var Mı Kontrol Et
                    var admin = context.Users.FirstOrDefault(u => u.Email != null && u.Email.ToLower() == adminEmail.ToLower());

                    if (admin == null)
                    {
                        // Projedeki özel PasswordHasher ile Hash ve Salt üretimi
                        PasswordHasher.CreatePasswordHash(adminPassword, out byte[] hash, out byte[] salt);

                        admin = new User
                        {
                            Email = adminEmail,
                            FirstName = firstName,
                            LastName = lastName,
                            PasswordHash = hash,
                            PasswordSalt = salt,
                            IsActive = true
                        };

                        context.Users.Add(admin);
                        context.SaveChanges(); // admin.Id veritabanından oluşması için ilk save
                    }

                    // 2. Admin Kullanıcısına Veritabanındaki Tüm İzinleri (Permissions) Tanımla
                    var allPermissions = context.Permissions.ToList();
                    var existingUserPermissions = context.UserPermissions
                        .Where(up => up.UserId == admin.Id)
                        .Select(up => up.PermissionId)
                        .ToHashSet();

                    var newAdminPermissions = new List<UserPermission>();

                    foreach (var perm in allPermissions)
                    {
                        if (!existingUserPermissions.Contains(perm.Id))
                        {
                            newAdminPermissions.Add(new UserPermission
                            {
                                UserId = admin.Id,
                                PermissionId = perm.Id
                            });
                        }
                    }

                    if (newAdminPermissions.Any())
                    {
                        context.UserPermissions.AddRange(newAdminPermissions);
                        context.SaveChanges();
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Default Admin oluşturma sırasında hata: {ex.Message}");
                }
            }

            return app;
        }
    }
}
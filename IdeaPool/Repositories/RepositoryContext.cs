using Entities.Models;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security;
using System.Text;
using System.Threading.Tasks;

namespace Repositories
{
    public class RepositoryContext : DbContext
    {
        public RepositoryContext(DbContextOptions<RepositoryContext> options) : base(options)
        {
        }
        public DbSet<User> Users { get; set; }
        public DbSet<Permission> Permissions { get; set; }
        public DbSet<UserPermission> UserPermissions { get; set; }
        public DbSet<Idea> Ideas { get; set; }
        public DbSet<IdeaEvaluation> IdeaEvaluations { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<UserPermission>()
                .HasKey(up => new { up.UserId, up.PermissionId });
            modelBuilder.Entity<User>().HasIndex(u => u.Email).IsUnique();
            modelBuilder.Entity<User>().HasIndex(u => u.RegistrationNumber).IsUnique();
            modelBuilder.Entity<User>().HasIndex(u => u.IdentityNumber).IsUnique();

            // 3 Temel Şartname Yetkisi Seed Verisi
            modelBuilder.Entity<Permission>().HasData(
                new Permission { Id = 1, Code = "FikirDegerlendirme", Description = "Fikir ve önerileri değerlendirme yetkisi" },
                new Permission { Id = 2, Code = "KullaniciYetkiEkleme", Description = "Kullanıcılara yeni yetki tanımlama yetkisi" },
                new Permission { Id = 3, Code = "KullaniciYetkiSilme", Description = "Kullanıcılardan yetki kaldırma yetkisi" }
            );

            // İlişki ayarları
            modelBuilder.Entity<Idea>()
                .HasOne(i => i.User)
                .WithMany(u => u.Ideas)
                .HasForeignKey(i => i.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<User>()
                .HasMany(u => u.FavoriteIdeas)
                .WithMany(i => i.FavoritedByUsers)
                .UsingEntity(j => j.ToTable("UserFavoriteIdeas"));
        }
    }
}

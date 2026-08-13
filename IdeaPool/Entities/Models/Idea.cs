using Entities.Enums;
using System;
using System.Collections.Generic;

namespace Entities.Models
{
    public class Idea
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public User User { get; set; } = null!;
        public string Title { get; set; } = string.Empty;
        public IdeaCategory Category { get; set; }
        public string Benefit { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string? DocumentUrl { get; set; } // YENİ EKLENEN ALAN (PDF Gereksinimi)
        public IdeaStatus Status { get; set; } = IdeaStatus.Beklemede;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public IdeaEvaluation? Evaluation { get; set; }
        public ICollection<User> FavoritedByUsers { get; set; } = new List<User>();
    }
}


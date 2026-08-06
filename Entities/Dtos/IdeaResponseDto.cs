using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Dtos
{
    public class IdeaResponseDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserFullName { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
        public string Benefit { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string? DocumentUrl { get; set; } // YENİ EKLENEN ALAN
        public string Status { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public IdeaEvaluationResponseDto? Evaluation { get; set; }
    }



}

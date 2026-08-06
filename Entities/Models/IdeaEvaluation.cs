using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Models
{
    public class IdeaEvaluation
    {
        public int Id { get; set; }
        public int IdeaId { get; set; }
        public Idea Idea { get; set; } = null!;
        public int EvaluatorUserId { get; set; }
        public User EvaluatorUser { get; set; } = null!;
        public bool IsApproved { get; set; }
        public string Explanation { get; set; } = string.Empty;
        public int Score { get; set; } // 1 - 100
        public DateTime EvaluatedAt { get; set; } = DateTime.Now;
    }

}

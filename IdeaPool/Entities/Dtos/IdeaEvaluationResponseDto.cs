using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Dtos
{
    public class IdeaEvaluationResponseDto
    {
        public int Id { get; set; }
        public int IdeaId { get; set; }
        public string EvaluatorFullName { get; set; } = string.Empty;
        public bool IsApproved { get; set; }
        public string Explanation { get; set; } = string.Empty;
        public int Score { get; set; }
        public DateTime EvaluatedAt { get; set; }
    }


}

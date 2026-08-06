using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Dtos
{
    public class IdeaEvaluationDto
    {
        public int IdeaId { get; set; }
        public bool IsApproved { get; set; }
        public string Explanation { get; set; }
        public int Score { get; set; }          // 1-100
    }


}

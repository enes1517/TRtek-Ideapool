using Entities.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Dtos
{
    public class CreateIdeaDto
    {
        public string Title { get; set; } = string.Empty;
        public IdeaCategory Category { get; set; }
        public string Benefit { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string? DocumentUrl { get; set; } // YENİ EKLENEN ALAN
    }



}

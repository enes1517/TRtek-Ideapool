
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Entities.Dtos
{
    public class GrantRevokeDto
    {
        public int UserId { get; set; }
        public int PermissionId { get; set; }
    }
}

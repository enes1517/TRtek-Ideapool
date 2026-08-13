using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories.Contracts
{
    public interface IRepositoryManager
    {
        IUserRepository User { get; }
        IPermissionRepository Permission { get; }
        IIdeaRepository Idea { get; }
        IEvaluationRepository Evaluation { get; }
        Task SaveAsync();
    }
}


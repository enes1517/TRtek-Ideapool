using Repositories.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Repositories
{
    public class RepositoryManager : IRepositoryManager
    {
        private readonly RepositoryContext _context;
        private readonly Lazy<IUserRepository> _userRepository;
        private readonly Lazy<IPermissionRepository> _permissionRepository;
        private readonly Lazy<IIdeaRepository> _ideaRepository;
        private readonly Lazy<IEvaluationRepository> _evaluationRepository;

        public RepositoryManager(RepositoryContext context)
        {
            _context = context;
            _userRepository = new Lazy<IUserRepository>(() => new UserRepository(_context));
            _permissionRepository = new Lazy<IPermissionRepository>(() => new PermissionRepository(_context));
            _ideaRepository = new Lazy<IIdeaRepository>(() => new IdeaRepository(_context));
            _evaluationRepository = new Lazy<IEvaluationRepository>(() => new EvaluationRepository(_context));
        }

        public IUserRepository User => _userRepository.Value;
        public IPermissionRepository Permission => _permissionRepository.Value;
        public IIdeaRepository Idea => _ideaRepository.Value;
        public IEvaluationRepository Evaluation => _evaluationRepository.Value;
        public async Task SaveAsync() => await _context.SaveChangesAsync();
    }
}


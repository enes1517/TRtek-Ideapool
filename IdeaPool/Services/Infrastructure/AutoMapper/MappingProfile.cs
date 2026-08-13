using AutoMapper;
using Entities.Dtos;
using Entities.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace Services.Infrastructure.AutoMapper
{
    public class MappingProfile: Profile
    {
        public MappingProfile()
        {
            CreateMap<User, UserResponseDto>();

            CreateMap<CreateUserDto, User>()
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordSalt, opt => opt.Ignore());


            CreateMap<UpdateUserDto, User>();

            CreateMap<Idea, IdeaResponseDto>()
                .ForMember(dest => dest.UserFullName,
                    opt => opt.MapFrom(src => $"{src.User.FirstName} {src.User.LastName}".Trim()))
                .ForMember(dest => dest.Category,
                    opt => opt.MapFrom(src => src.Category.ToString()))
                .ForMember(dest => dest.Status,
                    opt => opt.MapFrom(src => src.Status.ToString()));

                 CreateMap<IdeaEvaluation, IdeaEvaluationResponseDto>()
                .ForMember(dest => dest.EvaluatorFullName,
                    opt => opt.MapFrom(src => $"{src.EvaluatorUser.FirstName} {src.EvaluatorUser.LastName}".Trim()));

            CreateMap<CreateIdeaDto, Idea>();
            CreateMap<IdeaEvaluation, IdeaEvaluationResponseDto>()
                .ForMember(dest => dest.EvaluatorFullName,
                    opt => opt.MapFrom(src => $"{src.EvaluatorUser.FirstName} {src.EvaluatorUser.LastName}".Trim()));

            // IdeaEvaluationDto -> IdeaEvaluation
            CreateMap<IdeaEvaluationDto, IdeaEvaluation>();

            CreateMap<User, UserResponseDto>();

            CreateMap<GoogleRegisterDto, User>()
                .ForMember(dest => dest.FirstName, opt => opt.Ignore())
                .ForMember(dest => dest.LastName, opt => opt.Ignore())
                .ForMember(dest => dest.Email, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordSalt, opt => opt.Ignore());


        }

    }
}

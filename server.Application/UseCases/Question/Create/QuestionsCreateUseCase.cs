using System;
using System.Linq;
using System.Threading.Tasks;
using server.Application.UseCases.Question.Mapper;
using server.Communication.Requests;
using server.Communication.Responses;
using server.Domain.Interfaces;
using server.Exceptions;

namespace server.Application.UseCases.Question.Create;

public class QuestionsCreateUseCase(IRoomsRepository roomsRepository, IQuestionsRepository questionsRepository, IUnitOfWork unitOfWork)
{
    public async Task<ResponseQuestionJson> Execute(Guid roomId, RequestCreateQuestionJson request)
    {
        var result = await new QuestionsCreateValidation().ValidateAsync(request);
        if (result.IsValid is false)
            throw new ErrorOnValidationException(result.Errors.Select(e => e.ErrorMessage).ToList());

        var room = await roomsRepository.GetById(roomId);
        if (room is null)
            throw new NotFoundException(ResourcesErrorMessages.ROOM_DOESNT_EXISTS);

        var question = request.ToDomain(room);
        await questionsRepository.Create(question);
        await unitOfWork.Commit();

        return question.ToResponse();
    }
}
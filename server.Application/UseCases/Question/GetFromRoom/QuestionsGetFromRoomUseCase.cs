using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using server.Communication.Responses;
using server.Domain.Interfaces;

namespace server.Application.UseCases.Question.GetFromRoom;

public class QuestionsGetFromRoomUseCase(IQuestionsRepository questionsRepository)
{
    public async Task<List<ResponseQuestionJson>> Execute(Guid roomId)
    {
        var questions = await questionsRepository.GetFromRoom(roomId);
        return questions.ToResponse();
    }
}
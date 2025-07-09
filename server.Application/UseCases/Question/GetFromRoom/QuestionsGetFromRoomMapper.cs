using System.Collections.Generic;
using System.Linq;
using server.Communication.Responses;
using server.Domain.Entities;

namespace server.Application.UseCases.Question.GetFromRoom;

public static class QuestionsGetFromRoomMapper
{
    public static List<ResponseQuestionJson> ToResponse(this List<Questions> questions)
    {
        return questions.Select(question => new ResponseQuestionJson
        {
            Id = question.Id,
            Answer = question.Answer, 
            Question = question.Question,
            CreatedOn = question.CreatedOn
        }).ToList();
    }
}
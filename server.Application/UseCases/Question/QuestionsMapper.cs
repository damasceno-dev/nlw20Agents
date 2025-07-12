using System.Collections.Generic;
using System.Linq;
using server.Communication.Requests;
using server.Communication.Responses;
using server.Domain.Entities;

namespace server.Application.UseCases.Question.Mapper;

public static class QuestionsMapper
{
    public static Questions ToDomain(this RequestCreateQuestionJson request, Room room, string answer = "")
    {
        return new Questions
        {
            Question = request.Question,
            Answer = answer,
            Room = room,
        };
    }
    
    public static ResponseQuestionJson ToResponse(this Questions question)
    {
        return new ResponseQuestionJson
        {
            Id = question.Id,
            Question = question.Question,
            Answer = question.Answer,
            CreatedOn = question.CreatedOn
        };
    }
    
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
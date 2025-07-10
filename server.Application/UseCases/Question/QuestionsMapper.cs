using System.Collections.Generic;
using System.Linq;
using server.Communication.Requests;
using server.Communication.Responses;
using server.Domain.Entities;

namespace server.Application.UseCases.Question.Mapper;

public static class QuestionsMapper
{
    public static Questions ToDomain(this RequestCreateQuestionJson request, Room room)
    {
        return new Questions
        {
            Question = request.Question,
            Answer = request.Answer,
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
    
    public static Questions ToDomain(this string question, Room room)
    {
        return new Questions
        {
            Question = question,
            Answer = "",
            Room = room,
        };
    }
}
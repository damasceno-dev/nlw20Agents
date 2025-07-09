using System;
using server.Communication.Requests;
using server.Communication.Responses;
using server.Domain.Entities;

namespace server.Application.UseCases.Question.Create;

public static class QuestionCreateMapper
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
}
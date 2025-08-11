using FluentValidation;
using server.Communication.Requests;
using server.Exceptions;

namespace server.Application.UseCases.Question.Create;

public class QuestionsCreateValidation : AbstractValidator<RequestCreateQuestionJson>
{
    public QuestionsCreateValidation()
    {
        RuleFor(r => r.Question).NotEmpty().WithMessage(ResourcesErrorMessages.QUESTION_CANT_BE_EMPTY);
    }
}
using FluentValidation;
using server.Communication.Requests;
using server.Exceptions;

namespace server.Application.UseCases.Rooms.Create;

public class RoomCreateValidation : AbstractValidator<RequestRoomCreateJson>
{
    public RoomCreateValidation()
    {
        RuleFor(r => r.Name).NotEmpty().MinimumLength(1).WithMessage(ResourcesErrorMessages.ROOM_NAME_EMPTY_OR_TOO_SHORT);
    }
}
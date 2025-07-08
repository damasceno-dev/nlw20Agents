using server.Communication.Requests;
using server.Communication.Responses;
using server.Domain.Interfaces;
using server.Exceptions;

namespace server.Application.UseCases.Rooms.Create;

public class RoomCreateUseCase(IRoomsRepository roomsRepository, IUnitOfWork unitOfWork)
{
    public async Task<ResponseRoomJson> Execute(RequestRoomCreateJson request)
    {
        var validationResult = await new RoomCreateValidation().ValidateAsync(request);
        if (validationResult.IsValid is false)
        {
            throw new ErrorOnValidationException(validationResult.Errors.Select(e => e.ErrorMessage).ToList());
        }

        var room = request.ToDomain();

        await roomsRepository.Create(room);
        await unitOfWork.Commit();

        return room.ToResponse();
    }
}
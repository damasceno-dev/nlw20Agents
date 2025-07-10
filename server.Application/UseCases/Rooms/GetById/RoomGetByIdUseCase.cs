using System;
using System.Threading.Tasks;
using server.Application.UseCases.Rooms.Create;
using server.Communication.Responses;
using server.Domain.Interfaces;
using server.Exceptions;

namespace server.Application.UseCases.Rooms.GetById;

public class RoomGetByIdUseCase(IRoomsRepository roomsRepository)
{
    public async Task<ResponseRoomJson> Execute(Guid roomId)
    {
        var room = await roomsRepository.GetById(roomId);
        if (room is null)
            throw new NotFoundException(ResourcesErrorMessages.ROOM_DOESNT_EXISTS);

        return room.ToResponse();
    }
}
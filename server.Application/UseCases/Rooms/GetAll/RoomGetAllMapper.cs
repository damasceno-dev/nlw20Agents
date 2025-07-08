using server.Communication.Responses;
using server.Domain.Entities;

namespace server.Application.UseCases.Rooms.GetAll;

public static class RoomGetAllMapper
{
    public static ResponseRoomJson ToResponse(this Room room)
    {
        return new ResponseRoomJson
        {
            Id = room.Id,
            Name = room.Name
        };
    }
}
using server.Communication.Requests;
using server.Communication.Responses;
using server.Domain.Entities;

namespace server.Application.UseCases.Rooms.Create;

public static class RoomCreateMapper
{
    public static Room ToDomain(this RequestRoomCreateJson request)
    {
        return new Room
        {
            Name = request.Name,
            Description = request.Description
        };
    }

    public static ResponseRoomJson ToResponse(this Room room)
    {
        return new ResponseRoomJson
        {
            Id = room.Id,
            Name = room.Name,
            Description = room.Description
        };
    }
}
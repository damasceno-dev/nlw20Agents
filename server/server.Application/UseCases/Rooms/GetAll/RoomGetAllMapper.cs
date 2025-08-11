using System.Collections.Generic;
using System.Linq;
using server.Communication.Responses;
using server.Domain.Entities;
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
            Name = room.Name,
            Description = room.Description,
            QuestionsCount = room.Questions.Count,
            CreatedOn = room.CreatedOn
        };
    }
}
using server.Communication.Responses;
using server.Domain.Entities;
using server.Domain.Interfaces;

namespace server.Application.UseCases.Rooms.GetAll;

public class RoomGetAllUseCase(IRoomsRepository roomsRepository)
{
    public async Task<List<ResponseRoomJson>> Execute()
    {
        var rooms =  await roomsRepository.GetAll();
        return rooms.Select(room => room.ToResponse()).ToList();
    }
}
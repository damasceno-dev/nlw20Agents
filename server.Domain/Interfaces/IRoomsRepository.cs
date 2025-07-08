using server.Domain.Entities;

namespace server.Domain.Interfaces;

public interface IRoomsRepository
{
    public Task<List<Room>> GetAll();
}
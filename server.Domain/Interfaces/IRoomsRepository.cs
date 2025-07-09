using server.Domain.Entities;

namespace server.Domain.Interfaces;

public interface IRoomsRepository
{
    public Task<Room?> GetById(Guid id);
    public Task<List<Room>> GetAll();
    public Task Create(Room room);
}
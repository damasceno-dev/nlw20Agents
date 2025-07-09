using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Internal;
using server.Domain.Entities;
using server.Domain.Interfaces;

namespace server.Infrastructure.Repositories;

public class RoomsRepository(ServerDbContext dbContext) : IRoomsRepository
{
    public async Task<Room?> GetById(Guid id)
    {
        return await dbContext.Rooms.FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<List<Room>> GetAll()
    {
        return await dbContext.Rooms.Include(r => r.Questions).OrderBy(r => r.CreatedOn).AsNoTracking().ToListAsync();
    }

    public async Task Create(Room room)
    {
        await dbContext.Rooms.AddAsync(room);
    }
}
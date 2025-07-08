using Microsoft.EntityFrameworkCore;
using server.Domain.Entities;
using server.Domain.Interfaces;

namespace server.Infrastructure.Repositories;

public class RoomsRepository(ServerDbContext dbContext) : IRoomsRepository
{
    public async Task<List<Room>> GetAll()
    {
        return await dbContext.Rooms.OrderBy(r => r.CreatedOn).AsNoTracking().ToListAsync();
    }
}
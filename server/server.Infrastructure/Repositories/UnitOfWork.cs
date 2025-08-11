using server.Domain.Interfaces;

namespace server.Infrastructure.Repositories;

public class UnitOfWork(ServerDbContext dbContext) : IUnitOfWork
{
    public async Task Commit()
    {
        await dbContext.SaveChangesAsync();
    }
}
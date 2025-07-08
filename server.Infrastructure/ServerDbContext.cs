using Microsoft.EntityFrameworkCore;

namespace server.Infrastructure;

public class ServerDbContext : DbContext
{
    public ServerDbContext(DbContextOptions options) : base(options)
    {
        
    }
}
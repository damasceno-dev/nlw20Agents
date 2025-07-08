using Microsoft.EntityFrameworkCore;
using server.Domain.Entities;

namespace server.Infrastructure;

public class ServerDbContext : DbContext
{
    public ServerDbContext(DbContextOptions options) : base(options)
    {
        
    }
    
    public DbSet<Room> Rooms { get; set; }
}
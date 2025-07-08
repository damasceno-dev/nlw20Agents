using Microsoft.EntityFrameworkCore;
using server.Domain.Entities;

namespace server.Infrastructure;

public class ServerDbContext(DbContextOptions options)
    : DbContext(options)
{
    public DbSet<Room> Rooms { get; set; }
    public DbSet<Questions> Questions { get; set; }
}
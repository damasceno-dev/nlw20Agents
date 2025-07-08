namespace server.Domain.Entities;

public class Room : EntityBase
{
    public required string Name { get; set; }
    public required string Description { get; set; }
}
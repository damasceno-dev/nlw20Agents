namespace server.Domain.Entities;

public class Room : EntityBase
{
    public required string Name { get; set; }
    public required string Description { get; set; }
    public IList<Questions> Questions { get; set; } = [];
}
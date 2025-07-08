namespace server.Domain.Entities;

public class Questions : EntityBase
{
    public required string Question { get; set; }
    public string Answer { get; set; } = string.Empty;
    
    public Guid RoomId { get; set; }
    public required Room Room { get; set; }
}
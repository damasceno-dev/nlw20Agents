namespace server.Communication.Responses;

public class ResponseRoomJson
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int QuestionsCount { get; set; }
    public DateTime CreatedOn { get; set; }
}
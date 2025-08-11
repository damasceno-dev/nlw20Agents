namespace server.Communication.Responses;

public class ResponseQuestionJson
{
    public Guid Id { get; set; }
    public string Question { get; set; } = string.Empty;
    public string Answer { get; set; } = string.Empty;
    public DateTime CreatedOn { get; set; }
}
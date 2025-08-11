namespace server.Communication.Requests;

public class RequestCreateQuestionJson
{
    public required string Question { get; set; }
    public string Answer { get; set; } = string.Empty;
}
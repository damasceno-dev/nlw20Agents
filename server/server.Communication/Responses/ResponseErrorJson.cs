namespace server.Communication.Responses;

public class ResponseErrorJson(List<string> errorMessages)
{
    public ResponseErrorJson(string errorMessage) : this([errorMessage])
    {
    }
    public List<string> ErrorMessages { get; set; } = errorMessages;

    public string Method { get; set; } = string.Empty;
}
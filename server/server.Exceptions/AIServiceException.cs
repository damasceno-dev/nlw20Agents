using System.Net;

namespace server.Exceptions;

public class AIServiceException : ServerException
{
    public AIServiceException(string errorMessage) : base(errorMessage)
    {
    }

    public AIServiceException(string errorMessage, Exception innerException) : base(errorMessage, innerException)
    {
    }

    // AI service errors are typically returned as 502 Bad Gateway
    // since they represent failures in downstream services
    public override int GetStatusCode => (int)HttpStatusCode.BadGateway;

    // Return the error message as a list with a single item
    public override List<string> GetErrors => [Message];
}

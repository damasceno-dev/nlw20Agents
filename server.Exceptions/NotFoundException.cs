using System.Net;

namespace server.Exceptions;

public class NotFoundException(string errorMessage) : ServerException(errorMessage)
{
    public override int GetStatusCode => (int)HttpStatusCode.NotFound;
    public override List<string> GetErrors => [Message];
}
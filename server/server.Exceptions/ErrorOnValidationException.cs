using System.Net;

namespace server.Exceptions;

public class ErrorOnValidationException(List<string> errorsMessage) : ServerException(string.Empty)
{
    public override int GetStatusCode => (int)HttpStatusCode.BadRequest;
    public override List<string> GetErrors => errorsMessage;
}
namespace server.Exceptions;

public abstract class ServerException(string errorMessage)
    : SystemException(errorMessage)
{
    public abstract int StatusCode { get; }
    public abstract List<string> GetErrors { get; }
}
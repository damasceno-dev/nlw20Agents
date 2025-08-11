namespace server.Exceptions;

public abstract class ServerException
    : SystemException
{
    protected ServerException(string message) : base (message) { }
    protected ServerException(string message, Exception innerException) : base(message, innerException) { }
    public abstract int GetStatusCode { get; }
    public abstract List<string> GetErrors { get; }
}
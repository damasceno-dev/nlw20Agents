namespace server.Exceptions;

public abstract class ServerException
    : SystemException
{
    protected ServerException(string message) : base (message) { }
    public abstract int GetStatusCode { get; }
    public abstract List<string> GetErrors { get; }
}
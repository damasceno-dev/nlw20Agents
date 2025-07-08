using System;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.DependencyInjection;
using server.Communication.Responses;
using server.Exceptions;

namespace server.API.Filters;

public class ExceptionFilter : IExceptionFilter
{
    public void OnException(ExceptionContext context)
    {
        var environment = context.HttpContext.RequestServices.GetService<IWebHostEnvironment>();
        var errorMessage = environment?.EnvironmentName == "Development"? GetErrorDetail(context.Exception, context.HttpContext): ResourcesErrorMessages.UNKNOWN_ERROR;
            
        context.Result = context.Exception is ServerException serverException ? 
            new ObjectResult(new ResponseErrorJson(serverException.GetErrors)) { StatusCode = serverException.GetStatusCode} :
            new ObjectResult(new ResponseErrorJson(errorMessage)
            {
                Method = $"{context.HttpContext.Request.Method} {context.HttpContext.Request.Path}"
            }) {StatusCode = StatusCodes.Status500InternalServerError};
    }

    private static string GetErrorDetail(Exception exception, HttpContext httpContext)
    {
        var innerMessage = exception.InnerException?.Message ?? string.Empty;
        var truncatedMessage = innerMessage.Length > 150 ? innerMessage[..150] + "..." : innerMessage;
        return $"Método: {httpContext.Request.Method} {httpContext.Request.Path}, Erro: {exception.Message}, Exception: {truncatedMessage}";

    }
}
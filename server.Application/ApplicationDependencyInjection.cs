using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using server.Application.UseCases.Rooms.GetAll;

namespace server.Application;

public static class ApplicationDependencyInjection
{
    public static void AddApplication(this IServiceCollection services)
    {
        services.AddScoped<RoomGetAllUseCase>();
    }
}
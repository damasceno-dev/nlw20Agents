using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using server.Application.UseCases.Question.Create;
using server.Application.UseCases.Question.GetFromRoom;
using server.Application.UseCases.Question.UploadAudio;
using server.Application.UseCases.Rooms.Create;
using server.Application.UseCases.Rooms.GetAll;
using server.Application.UseCases.Rooms.GetById;

namespace server.Application;

public static class ApplicationDependencyInjection
{
    public static void AddApplication(this IServiceCollection services)
    {
        services.AddScoped<RoomGetAllUseCase>();
        services.AddScoped<RoomCreateUseCase>();
        services.AddScoped<RoomGetByIdUseCase>();
        services.AddScoped<QuestionsGetFromRoomUseCase>();
        services.AddScoped<QuestionsCreateUseCase>();
        services.AddScoped<QuestionsUploadAudioUseCase>();
    }
}
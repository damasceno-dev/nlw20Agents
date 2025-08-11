using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using server.Application.Services;
using server.Application.UseCases.Question.Mapper;
using server.Communication.Responses;
using server.Domain.Interfaces;
using server.Exceptions;

namespace server.Application.UseCases.Audio.Upload;

public class UploadAudioUseCase(IAudioRepository audioRepository,IRoomsRepository roomsRepository,IUnitOfWork unitOfWork, IArtificialIntelligenceService aiService)
{
    public async Task<ResponseAudioJson> Execute(IFormFile audioFile, Guid roomId)
    {
        var (isValid, error) = audioFile.ValidateAudioFile();
        if (isValid is false)
            throw new ErrorOnValidationException([error]);
        
        var room = await roomsRepository.GetById(roomId);
        if (room is null)
            throw new NotFoundException(ResourcesErrorMessages.ROOM_DOESNT_EXISTS);

        var transcription = await ProcessAudioFile(audioFile);
        var embedding = await aiService.GenerateEmbeddingsAsync(transcription);
        var audioChunk = transcription.ToDomain(embedding, room);

        await audioRepository.Create(audioChunk);
        await unitOfWork.Commit();

        return audioChunk.ToResponse();
    }

    private async Task<string> ProcessAudioFile(IFormFile audioFile)
    {
        using var memoryStream = new MemoryStream();
        await audioFile.CopyToAsync(memoryStream);
        var audioBytes = memoryStream.ToArray();
        var mimeType = audioFile.ContentType;

        return await aiService.TranscribeAudioAsync(audioBytes, mimeType);
    }
}
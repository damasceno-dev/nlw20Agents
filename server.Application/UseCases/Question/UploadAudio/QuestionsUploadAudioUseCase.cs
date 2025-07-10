using System;
using System.Linq;
using System.Threading.Tasks;
using server.Application.UseCases.Question.Create;
using server.Communication.Responses;
using server.Domain.Entities;
using server.Domain.Interfaces;
using server.Exceptions;
using Microsoft.AspNetCore.Http;
using server.Application.Services;
using server.Application.UseCases.Question.Mapper;


namespace server.Application.UseCases.Question.UploadAudio;

public class QuestionsUploadAudioUseCase(
    IQuestionsRepository questionsRepository,
    IRoomsRepository roomsRepository,
    IUnitOfWork unitOfWork)
{

    public async Task<ResponseQuestionJson> Execute(IFormFile audioFile, Guid roomId)
    {
        var (isValid, error) = audioFile.ValidateAudioFile();
        if (isValid is false)
            throw new ErrorOnValidationException([error]);
        
        var room = await roomsRepository.GetById(roomId);
        if (room is null)
            throw new NotFoundException(ResourcesErrorMessages.ROOM_DOESNT_EXISTS);

        var processedQuestion = await ProcessAudioFile(audioFile);
        var question = processedQuestion.ToDomain(room);

        await questionsRepository.Create(question);
        await unitOfWork.Commit();

        return question.ToResponse();
    }

    private async Task<string> ProcessAudioFile(IFormFile audioFile)
    {
        // TODO: Implement audio processing logic
        // This could include:
        // - Saving file to storage
        // - Converting speech to text
        // - Cleaning up the text
        // - etc.
        
        // For now, return a placeholder
        return "Question from audio file: " + audioFile.FileName;
    }
}
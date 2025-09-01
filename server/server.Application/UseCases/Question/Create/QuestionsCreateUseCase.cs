using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using server.Application.UseCases.Question.Mapper;
using server.Communication.Requests;
using server.Communication.Responses;
using server.Domain.Interfaces;
using server.Exceptions;

namespace server.Application.UseCases.Question.Create;

public class QuestionsCreateUseCase(
    IRoomsRepository roomsRepository, 
    IQuestionsRepository questionsRepository, 
    IAudioRepository audioRepository,
    IArtificialIntelligenceService aiService,
    IUnitOfWork unitOfWork,
    ILogger<QuestionsCreateUseCase> logger)
{
    public async Task<ResponseQuestionJson> Execute(Guid roomId, RequestCreateQuestionJson request)
    {
        logger.LogInformation("🚀 [QUESTION] Starting question creation process for room {RoomId}", roomId);
        logger.LogInformation("❓ [QUESTION] Question text: '{Question}'", request.Question);

        var result = await new QuestionsCreateValidation().ValidateAsync(request);
        if (result.IsValid is false)
        {
            logger.LogWarning("❌ [QUESTION] Validation failed for question: {Errors}", 
                string.Join(", ", result.Errors.Select(e => e.ErrorMessage)));
            throw new ErrorOnValidationException(result.Errors.Select(e => e.ErrorMessage).ToList());
        }

        var room = await roomsRepository.GetById(roomId);
        if (room is null)
        {
            logger.LogError("🏠 [QUESTION] Room {RoomId} not found", roomId);
            throw new NotFoundException(ResourcesErrorMessages.ROOM_DOESNT_EXISTS);
        }

        logger.LogInformation("🏠 [QUESTION] Found room: '{RoomName}' (ID: {RoomId})", room.Name, roomId);

        // Generate embeddings for the question
        logger.LogInformation("🔍 [QUESTION] Generating embeddings for question...");
        var questionEmbeddings = await aiService.GenerateEmbeddingsAsync(request.Question);
        
        // Find similar audio chunks
        logger.LogInformation("📊 [QUESTION] Searching for similar audio chunks in room {RoomId}...", roomId);
        var similarChunks = await audioRepository.FindSimilarChunksAsync(roomId, questionEmbeddings);
        
        logger.LogInformation("📦 [QUESTION] Found {Count} similar chunks", similarChunks.Count);
        
        var answer = string.Empty;
        
        if (similarChunks.Count > 0)
        {
            logger.LogInformation("✅ [QUESTION] Processing {Count} similar chunks for answer generation", similarChunks.Count);
            
            // Log details of found chunks
            for (int i = 0; i < similarChunks.Count; i++)
            {
                var chunk = similarChunks[i];
                var preview = chunk.Transcription.Length > 100 
                    ? chunk.Transcription.Substring(0, 100) + "..." 
                    : chunk.Transcription;
                logger.LogDebug("📝 [QUESTION] Chunk {Index} (ID: {ChunkId}): '{Preview}' (length: {Length} chars)", 
                    i + 1, chunk.Id, preview, chunk.Transcription.Length);
            }
            
            var transcriptions = similarChunks.Select(ac => ac.Transcription).ToList();
            logger.LogInformation("🤖 [QUESTION] Requesting answer generation from AI service...");
            answer = await aiService.GenerateAnswerAsync(request.Question, transcriptions);
            
            logger.LogInformation("✅ [QUESTION] AI generated answer (length: {Length} chars): '{Answer}'", 
                answer.Length, answer.Length > 200 ? answer.Substring(0, 200) + "..." : answer);
        }
        else
        {
            logger.LogWarning("⚠️ [QUESTION] No similar chunks found - answer will be empty");
        }

        var question = request.ToDomain(room, answer);
        
        logger.LogInformation("💾 [QUESTION] Saving question to database...");
        await questionsRepository.Create(question);
        await unitOfWork.Commit();
        
        logger.LogInformation("🎉 [QUESTION] Question created successfully with ID: {QuestionId}", question.Id);

        return question.ToResponse();
    }
}
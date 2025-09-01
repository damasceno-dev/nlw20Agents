using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Pgvector;
using server.Domain.Entities;
using server.Domain.Interfaces;

namespace server.Infrastructure.Repositories;

public class AudioRepository(ServerDbContext dbContext, ILogger<AudioRepository> logger) : IAudioRepository
{
    public async Task Create(AudioChunk audioChunk)
    {
        await dbContext.AudioChunks.AddAsync(audioChunk);
    }

    public async Task<List<AudioChunk>> FindSimilarChunksAsync(Guid roomId, float[] questionEmbeddings, int limit = 5, double similarityThreshold = 0.7)
    {
        logger.LogInformation("🔍 [AUDIO] Starting similarity search for room {RoomId} with threshold {Threshold} and limit {Limit}", 
            roomId, similarityThreshold, limit);
        
        // Log embedding info
        var embeddingPreview = string.Join(", ", questionEmbeddings.Take(5).Select(x => x.ToString("F4")));
        logger.LogDebug("📊 [AUDIO] Question embedding preview (first 5): [{Preview}]", embeddingPreview);

        var questionVector = new Vector(questionEmbeddings);
        
        logger.LogInformation("🗄️ [AUDIO] Executing vector similarity query...");
        var similarChunks = await dbContext.AudioChunks
            .FromSqlRaw(@"
                SELECT * FROM ""AudioChunks"" 
                WHERE ""RoomId"" = {0} AND ""Active"" = true 
                ORDER BY ""Embeddings"" <=> {1} 
                LIMIT {2}", roomId, questionVector, limit)
            .ToListAsync();

        logger.LogInformation("📦 [AUDIO] Raw SQL query returned {Count} chunks", similarChunks.Count);

        if (similarChunks.Count == 0)
        {
            logger.LogWarning("⚠️ [AUDIO] No audio chunks found for room {RoomId}. Check if audio was uploaded and processed.", roomId);
            return similarChunks;
        }

        // Filter by similarity threshold
        // The <=> operator returns cosine distance (0 = perfect similarity, 2 = completely opposite)
        var maxDistance = 1 - similarityThreshold;
        logger.LogInformation("🎯 [AUDIO] Filtering chunks with max distance {MaxDistance} (from threshold {Threshold})", 
            maxDistance, similarityThreshold);
        
        var filteredChunks = similarChunks
            .Where(ac => 
            {
                // Calculate cosine distance manually for filtering
                var distance = CalculateCosineDistance(ac.Embeddings.ToArray(), questionEmbeddings);
                var passed = distance <= maxDistance;
                
                logger.LogDebug("📐 [AUDIO] Chunk {ChunkId}: distance={Distance:F4}, threshold={MaxDistance:F4}, passed={Passed}", 
                    ac.Id, distance, maxDistance, passed);
                
                if (passed)
                {
                    var preview = ac.Transcription.Length > 100 
                        ? ac.Transcription.Substring(0, 100) + "..." 
                        : ac.Transcription;
                    logger.LogInformation("✅ [AUDIO] Selected chunk {ChunkId} (distance: {Distance:F4}): '{Preview}'", 
                        ac.Id, distance, preview);
                }
                
                return passed;
            })
            .ToList();

        logger.LogInformation("🎉 [AUDIO] After filtering: {FilteredCount}/{TotalCount} chunks meet similarity threshold", 
            filteredChunks.Count, similarChunks.Count);

        if (filteredChunks.Count == 0)
        {
            logger.LogWarning("⚠️ [AUDIO] No chunks passed similarity threshold {Threshold}. Consider lowering the threshold or check audio quality.", 
                similarityThreshold);
            
            // Log the closest chunk for debugging
            if (similarChunks.Count > 0)
            {
                var closest = similarChunks[0];
                var closestDistance = CalculateCosineDistance(closest.Embeddings.ToArray(), questionEmbeddings);
                logger.LogInformation("🔍 [AUDIO] Closest chunk distance was {Distance:F4} (required: <={Required:F4})", 
                    closestDistance, maxDistance);
            }
        }

        return filteredChunks;
    }

    private static double CalculateCosineDistance(float[] vector1, float[] vector2)
    {
        if (vector1.Length != vector2.Length)
            return 2.0; // Maximum distance for different dimensions

        double dotProduct = 0;
        double norm1 = 0;
        double norm2 = 0;

        for (int i = 0; i < vector1.Length; i++)
        {
            dotProduct += vector1[i] * vector2[i];
            norm1 += vector1[i] * vector1[i];
            norm2 += vector2[i] * vector2[i];
        }

        norm1 = Math.Sqrt(norm1);
        norm2 = Math.Sqrt(norm2);

        if (norm1 == 0 || norm2 == 0)
            return 1.0; // Maximum distance for zero vectors

        double cosineSimilarity = dotProduct / (norm1 * norm2);
        return 1 - cosineSimilarity; // Convert to distance
    }
}
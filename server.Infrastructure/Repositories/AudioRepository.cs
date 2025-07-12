using Microsoft.EntityFrameworkCore;
using Pgvector;
using server.Domain.Entities;
using server.Domain.Interfaces;

namespace server.Infrastructure.Repositories;

public class AudioRepository(ServerDbContext dbContext) : IAudioRepository
{
    public async Task Create(AudioChunk audioChunk)
    {
        await dbContext.AudioChunks.AddAsync(audioChunk);
    }

    public async Task<List<AudioChunk>> FindSimilarChunksAsync(Guid roomId, float[] questionEmbeddings, int limit = 5, double similarityThreshold = 0.7)
    {
        var questionVector = new Vector(questionEmbeddings);
        var similarChunks = await dbContext.AudioChunks
            .FromSqlRaw(@"
                SELECT * FROM ""AudioChunks"" 
                WHERE ""RoomId"" = {0} AND ""Active"" = true 
                ORDER BY ""Embeddings"" <=> {1} 
                LIMIT {2}", roomId, questionVector, limit)
            .ToListAsync();

        Console.WriteLine($@"Raw SQL query returned {similarChunks.Count} chunks");

        // Filter by similarity threshold
        // The <=> operator returns cosine distance (0 = perfect similarity, 2 = completely opposite)
        var maxDistance = 1 - similarityThreshold;
        var filteredChunks = similarChunks
            .Where(ac => 
            {
                // Calculate cosine distance manually for filtering
                var distance = CalculateCosineDistance(ac.Embeddings.ToArray(), questionEmbeddings);
                Console.WriteLine($@"Chunk {ac.Id}: distance = {distance:F4}, threshold = {maxDistance:F4}");
                return distance <= maxDistance;
            })
            .ToList();

        Console.WriteLine($@"After filtering: {filteredChunks.Count} chunks meet similarity threshold");

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
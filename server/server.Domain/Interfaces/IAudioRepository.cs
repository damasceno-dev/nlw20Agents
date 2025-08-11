using server.Domain.Entities;

namespace server.Domain.Interfaces;

public interface IAudioRepository
{
    Task Create(AudioChunk audioChunk);
    Task<List<AudioChunk>> FindSimilarChunksAsync(Guid roomId, float[] questionEmbeddings, int limit = 5, double similarityThreshold = 0.7);
}
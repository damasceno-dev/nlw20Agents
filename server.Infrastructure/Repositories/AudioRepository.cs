using server.Domain.Entities;
using server.Domain.Interfaces;

namespace server.Infrastructure.Repositories;

public class AudioRepository(ServerDbContext dbContext) : IAudioRepository
{
    public async Task Create(AudioChunk audioChunk)
    {
        await dbContext.AudioChunks.AddAsync(audioChunk);
    }
}
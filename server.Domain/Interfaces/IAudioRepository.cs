using server.Domain.Entities;

namespace server.Domain.Interfaces;

public interface IAudioRepository
{
    Task Create(AudioChunk audioChunk);
}
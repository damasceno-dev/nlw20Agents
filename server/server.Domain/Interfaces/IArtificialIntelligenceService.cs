namespace server.Domain.Interfaces;

public interface IArtificialIntelligenceService
{
    Task<string> TranscribeAudioAsync(byte[] audioData, string mimeType);
    Task<float[]> GenerateEmbeddingsAsync(string text);
    Task<string> GenerateAnswerAsync(string question, List<string> transcriptions);
} 
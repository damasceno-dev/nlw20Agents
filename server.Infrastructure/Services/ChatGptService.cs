using Microsoft.Extensions.Configuration;
using OpenAI;
using OpenAI.Audio;
using OpenAI.Chat;
using OpenAI.Embeddings;
using server.Domain.Interfaces;
using server.Exceptions;

namespace server.Infrastructure.Services;

public class ChatGptService : IArtificialIntelligenceService
{
    private readonly AudioClient _audioClient;
    private readonly ChatClient _chatClient;
    private readonly EmbeddingClient _embeddingClient;

    public ChatGptService(IConfiguration configuration)
    {
        var apiKey = configuration["OpenAI:ApiKey"];
        var openAIClient = new OpenAIClient(apiKey);

        // Initialize specific clients
        _audioClient = openAIClient.GetAudioClient("whisper-1");
        _chatClient = openAIClient.GetChatClient("gpt-4-turbo");
        _embeddingClient = openAIClient.GetEmbeddingClient("text-embedding-3-small");
    }

    public async Task<string> TranscribeAudioAsync(byte[] audioData, string mimeType)
    {
        try
        {
            // Convert byte array to stream
            using var audioStream = new MemoryStream(audioData);
            
            // Create transcription options
            var options = new AudioTranscriptionOptions
            {
                Language = "pt", // Portuguese
                ResponseFormat = AudioTranscriptionFormat.Text,
                Prompt = ResourcesPrompts.AUDIO_TRANSCRIPTION_PROMPT
            };

            // Get transcription
            var transcription = await _audioClient.TranscribeAudioAsync(audioStream, "audio.wav", options);
            
            if (string.IsNullOrEmpty(transcription.Value.Text))
            {
                throw new AIServiceException(ResourcesErrorMessages.OPENAI_AUDIO_TRANSCRIPTION_FAILED);
            }

            return transcription.Value.Text;
        }
        catch (Exception ex)
        {
            throw new AIServiceException(string.Format(ResourcesErrorMessages.OPENAI_TRANSCRIBE_AUDIO_ERROR, ex.Message), ex);
        }
    }

    public async Task<float[]> GenerateEmbeddingsAsync(string text)
    {
        try
        {
            var embeddingOptions = new EmbeddingGenerationOptions
            {
                Dimensions = 1536 // Default dimension for text-embedding-3-small
            };

            var response = await _embeddingClient.GenerateEmbeddingAsync(text, embeddingOptions);
            
            if (response.Value == null)
            {
                throw new AIServiceException(ResourcesErrorMessages.OPENAI_EMBEDDINGS_GENERATION_FAILED);
            }

            return response.Value.ToFloats().ToArray();
        }
        catch (Exception ex)
        {
            throw new AIServiceException(string.Format(ResourcesErrorMessages.OPENAI_GENERATE_EMBEDDINGS_ERROR, ex.Message), ex);
        }
    }

    public async Task<string> GenerateAnswerAsync(string question, List<string> transcriptions)
    {
        try
        {
            var context = string.Join("\n\n", transcriptions);

            var prompt = string.Format(ResourcesPrompts.ANSWER_GENERATION_PROMPT, context, question);

            var messages = new List<ChatMessage>
            {
                new SystemChatMessage(ResourcesPrompts.ANSWER_GENERATION_SYSTEM_PROMPT),
                new UserChatMessage(prompt)
            };

            var options = new ChatCompletionOptions
            {
                MaxOutputTokenCount = 2000,
                Temperature = 0.7f
            };

            var response = await _chatClient.CompleteChatAsync(messages, options);

            if (response.Value?.Content == null || response.Value.Content.Count == 0)
            {
                throw new AIServiceException(ResourcesErrorMessages.OPENAI_RESPONSE_FAILED);
            }

            return response.Value.Content[0].Text;
        }
        catch (Exception ex)
        {
            throw new AIServiceException(string.Format(ResourcesErrorMessages.OPENAI_GENERATE_ANSWER_ERROR, ex.Message), ex);
        }
    }
}
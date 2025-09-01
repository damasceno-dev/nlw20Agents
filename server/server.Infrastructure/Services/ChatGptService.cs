using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
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
    private readonly ILogger<ChatGptService> _logger;

    public ChatGptService(IConfiguration configuration, ILogger<ChatGptService> logger)
    {
        _logger = logger;
        var apiKey = configuration["OpenAI:ApiKey"];
        var openAIClient = new OpenAIClient(apiKey);

        // Initialize specific clients
        _audioClient = openAIClient.GetAudioClient("whisper-1");
        _chatClient = openAIClient.GetChatClient("gpt-4-turbo");
        _embeddingClient = openAIClient.GetEmbeddingClient("text-embedding-3-small");
        
        _logger.LogInformation("ChatGPT Service initialized successfully");
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
            _logger.LogInformation("🔍 [EMBEDDINGS] Starting embedding generation for text: '{Text}' (length: {Length} chars)", 
                text.Length > 100 ? text.Substring(0, 100) + "..." : text, text.Length);

            var embeddingOptions = new EmbeddingGenerationOptions
            {
                Dimensions = 1536 // Default dimension for text-embedding-3-small
            };

            var response = await _embeddingClient.GenerateEmbeddingAsync(text, embeddingOptions);
            
            if (response.Value == null)
            {
                _logger.LogError("❌ [EMBEDDINGS] Response value is null");
                throw new AIServiceException(ResourcesErrorMessages.OPENAI_EMBEDDINGS_GENERATION_FAILED);
            }

            var embeddings = response.Value.ToFloats().ToArray();
            _logger.LogInformation("✅ [EMBEDDINGS] Successfully generated {Count} dimensional embeddings", embeddings.Length);
            
            // Log first few values for debugging
            var firstFew = string.Join(", ", embeddings.Take(5).Select(x => x.ToString("F4")));
            _logger.LogDebug("📊 [EMBEDDINGS] First 5 values: [{Values}]", firstFew);

            return embeddings;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "💥 [EMBEDDINGS] Error generating embeddings for text: '{Text}'", text);
            throw new AIServiceException(string.Format(ResourcesErrorMessages.OPENAI_GENERATE_EMBEDDINGS_ERROR, ex.Message), ex);
        }
    }

    public async Task<string> GenerateAnswerAsync(string question, List<string> transcriptions)
    {
        try
        {
            _logger.LogInformation("🤖 [CHAT] Starting answer generation for question: '{Question}'", question);
            _logger.LogInformation("📄 [CHAT] Using {Count} transcription chunks as context", transcriptions.Count);

            // Log each transcription for debugging
            for (int i = 0; i < transcriptions.Count; i++)
            {
                var preview = transcriptions[i].Length > 100 ? transcriptions[i].Substring(0, 100) + "..." : transcriptions[i];
                _logger.LogDebug("📝 [CHAT] Transcription {Index}: '{Text}' (length: {Length} chars)", 
                    i + 1, preview, transcriptions[i].Length);
            }

            var context = string.Join("\n\n", transcriptions);
            _logger.LogDebug("🔗 [CHAT] Combined context length: {Length} chars", context.Length);

            var prompt = string.Format(ResourcesPrompts.ANSWER_GENERATION_PROMPT, context, question);
            _logger.LogDebug("💬 [CHAT] Generated prompt length: {Length} chars", prompt.Length);

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

            _logger.LogInformation("🚀 [CHAT] Sending request to GPT-4-turbo with {TokenLimit} token limit, temperature {Temp}", 
                options.MaxOutputTokenCount, options.Temperature);

            var response = await _chatClient.CompleteChatAsync(messages, options);

            if (response.Value?.Content == null || response.Value.Content.Count == 0)
            {
                _logger.LogError("❌ [CHAT] Response content is null or empty");
                throw new AIServiceException(ResourcesErrorMessages.OPENAI_RESPONSE_FAILED);
            }

            var answer = response.Value.Content[0].Text;
            _logger.LogInformation("✅ [CHAT] Successfully generated answer (length: {Length} chars): '{Answer}'", 
                answer.Length, answer.Length > 200 ? answer.Substring(0, 200) + "..." : answer);

            return answer;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "💥 [CHAT] Error generating answer for question: '{Question}'", question);
            throw new AIServiceException(string.Format(ResourcesErrorMessages.OPENAI_GENERATE_ANSWER_ERROR, ex.Message), ex);
        }
    }
}
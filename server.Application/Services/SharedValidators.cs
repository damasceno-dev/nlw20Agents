using System.Collections.Generic;
using Microsoft.AspNetCore.Http;
using server.Exceptions;

namespace server.Application.Services;

public static class SharedValidators
{
    private const int MaxAudioFileSizeMb = 10;
    private const int MaxAudioFileSize = 10 * 1024 * 1024; // 10MB

    private static readonly List<string?> AllowedAudioTypes = ["audio/mpeg", "audio/wav", "audio/mp3", "audio/ogg","audio/mp4","audio/flac","audio/x-wav","audio/webm"];

    public static (bool isValidAudio,  string errorMessage) ValidateAudioFile(this IFormFile? audioFile)
    {
        if (audioFile == null || audioFile.Length == 0)
            return (false, ResourcesErrorMessages.AUDIO_NOT_FOUND);

        if (audioFile.Length > MaxAudioFileSize)
            return (false, string.Format(ResourcesErrorMessages.AUDIO_SIZE_EXCEEDED, MaxAudioFileSizeMb));

        if (AllowedAudioTypes.Contains(audioFile.ContentType?.ToLower()) is false)
            return (false, ResourcesErrorMessages.AUDIO_INVALID_FORMAT); 

        using var stream = audioFile.OpenReadStream();
        var isValidExtension = stream.ValidateAudioExtension();

        if (isValidExtension is false)
            return (false, ResourcesErrorMessages.AUDIO_INVALID_TYPE); 
        
        return (true,  string.Empty);
    }

}
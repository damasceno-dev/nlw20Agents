using Pgvector;
using server.Communication.Responses;
using server.Domain.Entities;

namespace server.Application.UseCases.Audio.Upload;

public static class UploadAudioMapper
{
    public static AudioChunk ToDomain(this string transcription, float[] embeddings, Room room)
    {
        return new AudioChunk
        {
            Transcription = transcription,
            Embeddings = new Vector(embeddings),
            Room = room
        };
    }

    public static ResponseAudioJson ToResponse(this AudioChunk audio)
    {
        return new ResponseAudioJson
        {
            Transcription = audio.Transcription,
            CreatedOn = audio.CreatedOn,
            Embeddings = audio.Embeddings.ToArray()
        };
    }
}
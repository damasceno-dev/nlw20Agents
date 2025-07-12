namespace server.Communication.Responses;

public class ResponseAudioJson
{
    public string Transcription { get; set; } = string.Empty;
    public DateTime CreatedOn { get; set; }
    public float[]? Embeddings { get; set; }
}
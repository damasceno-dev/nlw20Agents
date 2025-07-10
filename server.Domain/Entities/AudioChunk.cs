using System.ComponentModel.DataAnnotations;
using Pgvector;

namespace server.Domain.Entities;

public class AudioChunk : EntityBase
{

    [MaxLength(10000)]
    public string Transcription { get; set; } = string.Empty;

    public Vector Embeddings { get; set; } = new(new float[768]);

    public Guid RoomId { get; set; }
    public required Room Room { get; set; } = null!;
}
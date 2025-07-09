using server.Domain.Entities;

namespace server.Domain.Interfaces;

public interface IQuestionsRepository
{
    Task Create(Questions question);
    Task<List<Questions>> GetFromRoom(Guid roomId);
}
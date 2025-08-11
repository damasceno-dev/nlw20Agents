using Microsoft.EntityFrameworkCore;
using server.Domain.Entities;
using server.Domain.Interfaces;

namespace server.Infrastructure.Repositories;

public class QuestionsRepository(ServerDbContext dbContext) : IQuestionsRepository
{
    public async Task Create(Questions question)
    {
        await dbContext.Questions.AddAsync(question);
    }

    public async Task<List<Questions>> GetFromRoom(Guid roomId)
    {
        return await dbContext.Questions.Where(q => q.RoomId == roomId).ToListAsync();
    }
}
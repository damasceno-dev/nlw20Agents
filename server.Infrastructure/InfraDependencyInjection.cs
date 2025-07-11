using Bogus;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using server.Domain.Entities;
using server.Domain.Interfaces;
using server.Infrastructure.Repositories;
using server.Infrastructure.Services;

namespace server.Infrastructure;

public static class InfraDependencyInjection
{
    public static void AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        AddDbContext(services, configuration);
        AddRepositories(services);
        AddServices(services);
    }

    private static void AddRepositories(IServiceCollection services)
    {
        services.AddScoped<IRoomsRepository, RoomsRepository>();
        services.AddScoped<IQuestionsRepository, QuestionsRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();
    }

    private static void AddServices(IServiceCollection services)
    {
        services.AddScoped<IArtificialIntelligenceService, ChatGptService>();
    }

    private static void AddDbContext(IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection");
        
        if (connectionString is null)
            throw new ArgumentException("Invalid connection string");

        services.AddDbContext<ServerDbContext>(options => options.UseNpgsql(connectionString, o=> o.UseVector()));
    }

    public static async Task SeedDatabase(this IServiceProvider serviceProvider)
    {
        using var scope = serviceProvider.CreateScope();
        var scopedServices = scope.ServiceProvider;

        try
        {
            Console.WriteLine("Seeding...");
            var dbContext = scopedServices.GetRequiredService<ServerDbContext>();
            
            if (await dbContext.Rooms.AnyAsync())
            {
                Console.WriteLine("Database already seeded");
                return;
            }
            
            var roomFaker = new Faker<Room>()
                .RuleFor(r => r.Name, f => f.Company.CompanyName() + " Room")
                .RuleFor(r => r.Description, f => f.Lorem.Sentence(10));
        
            var rooms = roomFaker.Generate(20);
        
            dbContext.Rooms.AddRange(rooms);
            await dbContext.SaveChangesAsync();
            // Create questions for each room - some with answers, some without
            var questionFaker = new Faker<Questions>()
                .RuleFor(q => q.Question, f => f.Lorem.Sentence() + "?")
                .RuleFor(q => q.Answer, f => f.Random.Bool(0.6f) ? f.Lorem.Sentence(5) : string.Empty); // 60% chance to have an answer
        
            var allQuestions = new List<Questions>();
        
            foreach (var room in rooms)
            {
                var questionsForRoom = questionFaker.Generate(5);
            
                foreach (var question in questionsForRoom)
                {
                    question.RoomId = room.Id;
                    question.Room = room;
                }
            
                allQuestions.AddRange(questionsForRoom);
            }
        
            dbContext.Questions.AddRange(allQuestions);
            await dbContext.SaveChangesAsync();
        
            var answeredCount = allQuestions.Count(q => !string.IsNullOrEmpty(q.Answer));
            var unansweredCount = allQuestions.Count - answeredCount;
        
            Console.WriteLine($"Seeded successfully: {rooms.Count} rooms with {allQuestions.Count} total questions");
            Console.WriteLine($"  - {answeredCount} questions with answers");
            Console.WriteLine($"  - {unansweredCount} questions without answers");


        }
        catch (Exception e)
        {
            Console.WriteLine($@"An error occurred during database migration: {e.Message}");
            throw;
        }
    }
}
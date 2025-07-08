using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace server.API;

public static class ApiDependencyInjection
{
    public static void AddApi(this IServiceCollection services, IWebHostEnvironment environment)
    {
        // Add CORS
        services.AddCors(options =>
        {
            if (environment.IsDevelopment())
            {
                options.AddPolicy("AllowFrontend", policy =>
                {
                    policy.WithOrigins(
                            "http://localhost:3000",
                            "https://localhost:3000",
                            "http://localhost:5173", // Vite default port
                            "https://localhost:5173"
                        )
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials();
                });
            }
            else
            {
                options.AddPolicy("AllowFrontend", policy =>
                {
                    policy.WithOrigins("https://yourdomain.com") // Replace with your production domain
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials();
                });
            }
        });

    }
}
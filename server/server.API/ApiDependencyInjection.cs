using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.Linq;

namespace server.API;

public static class ApiDependencyInjection
{
    public static void AddApi(this IServiceCollection services, IWebHostEnvironment environment)
    {
        // Add CORS
        // Resolve IConfiguration from a temporary ServiceProvider built from current services
        using var sp = services.BuildServiceProvider();
        var config = sp.GetRequiredService<IConfiguration>();
        var allowedOriginsFromConfig = config["Cors:AllowedOrigins"] ?? string.Empty;
        var allowedOrigins = allowedOriginsFromConfig
            .Split(new[] { ',', ';', ' ' }, System.StringSplitOptions.RemoveEmptyEntries)
            .Select(o => o.Trim())
            .ToArray();

        services.AddCors(options =>
        {
            options.AddPolicy("AllowFrontend", policy =>
            {
                if (environment.IsDevelopment())
                {
                    policy.WithOrigins(new[]
                        {
                            "http://localhost:3000",
                            "https://localhost:3000",
                            "http://localhost:5173",
                            "https://localhost:5173"
                        }
                        .Concat(allowedOrigins)
                        .Distinct()
                        .ToArray())
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials();
                }
                else
                {
                    // In production, rely on Cors:AllowedOrigins, falling back to App Runner URL inferred domain if provided via env
                    if (allowedOrigins.Length > 0)
                    {
                        policy.WithOrigins(allowedOrigins)
                            .AllowAnyHeader()
                            .AllowAnyMethod()
                            .AllowCredentials();
                    }
                    else
                    {
                        // Default to deny all external origins to avoid open CORS when none are configured
                        policy
                            .SetIsOriginAllowed(_ => false)
                            .AllowAnyHeader()
                            .AllowAnyMethod();
                    }
                }
            });
        });

    }
}
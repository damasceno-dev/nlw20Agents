using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Linq;

namespace server.API;

public static class ApiDependencyInjection
{
    public static void AddApi(this IServiceCollection services, IWebHostEnvironment environment, IConfiguration configuration)
    {
        // Add CORS
        services.AddCors(options =>
        {
            options.AddPolicy("AllowFrontend", policy =>
            {
                if (environment.IsDevelopment())
                {
                    // Development: Allow common local ports
                    var devOrigins = new[]
                    {
                        "http://localhost:3000",
                        "https://localhost:3000",
                        "http://localhost:5173",
                        "https://localhost:5173"
                    };
                    
                    // Also include any configured origins for testing
                    var additionalOrigins = GetConfiguredOrigins(configuration);
                    var allDevOrigins = devOrigins.Concat(additionalOrigins).Distinct().ToArray();
                    
                    policy.WithOrigins(allDevOrigins)
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials();
                    
                    Console.WriteLine($"CORS (Dev) configured with origins: {string.Join(", ", allDevOrigins)}");
                }
                else
                {
                    // Production: Use configured origins or secure defaults
                    var allowedOrigins = GetConfiguredOrigins(configuration);
                    
                    if (allowedOrigins.Length > 0)
                    {
                        // Validate all production origins use HTTPS
                        var invalidOrigins = allowedOrigins
                            .Where(o => !o.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                            .ToArray();
                        
                        if (invalidOrigins.Any())
                        {
                            Console.WriteLine($"⚠️ WARNING: Non-HTTPS origins detected in production: {string.Join(", ", invalidOrigins)}");
                        }
                        
                        policy.WithOrigins(allowedOrigins)
                            .AllowAnyHeader()
                            .AllowAnyMethod()
                            .AllowCredentials();
                        
                        Console.WriteLine($"CORS (Prod) configured with origins: {string.Join(", ", allowedOrigins)}");
                    }
                    else
                    {
                        // Fallback: Allow Amplify domains pattern
                        policy.SetIsOriginAllowed(origin =>
                        {
                            if (!Uri.TryCreate(origin, UriKind.Absolute, out var uri))
                                return false;
                            
                            // Only allow HTTPS in production
                            if (uri.Scheme != "https")
                                return false;
                            
                            // Allow Amplify app domains
                            return uri.Host.EndsWith(".amplifyapp.com", StringComparison.OrdinalIgnoreCase) ||
                                   uri.Host.EndsWith(".amazonaws.com", StringComparison.OrdinalIgnoreCase);
                        })
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials();
                        
                        Console.WriteLine("CORS (Prod) configured with Amplify domain pattern (fallback)");
                    }
                }
            });
        });
    }
    
    private static string[] GetConfiguredOrigins(IConfiguration configuration)
    {
        // Support both Cors:AllowedOrigins and Cors__AllowedOrigins (environment variable format)
        var originsConfig = configuration["Cors:AllowedOrigins"] ?? 
                           configuration["Cors__AllowedOrigins"] ?? 
                           string.Empty;
        
        // Split by multiple possible delimiters and clean up
        return originsConfig
            .Split(new[] { ',', ';', ' ', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries)
            .Select(o => o.Trim())
            .Where(o => !string.IsNullOrWhiteSpace(o))
            .Distinct()
            .ToArray();
    }
}
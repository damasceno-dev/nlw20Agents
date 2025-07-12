using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace server.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class UpdateVectorDimensions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Update the vector column to specify dimensions for better performance
            // This ensures all vectors in the Embeddings column are 1536-dimensional
            migrationBuilder.Sql(@"
                ALTER TABLE ""AudioChunks"" 
                ALTER COLUMN ""Embeddings"" TYPE vector(1536);
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Revert to generic vector type
            migrationBuilder.Sql(@"
                ALTER TABLE ""AudioChunks"" 
                ALTER COLUMN ""Embeddings"" TYPE vector;
            ");
        }
    }
}

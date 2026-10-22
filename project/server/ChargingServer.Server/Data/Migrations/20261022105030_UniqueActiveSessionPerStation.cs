using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ChargingServer.Server.Data.Migrations
{
    /// <inheritdoc />
    public partial class UniqueActiveSessionPerStation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Sessions_StationId",
                table: "Sessions");

            migrationBuilder.CreateIndex(
                name: "IX_Sessions_StationId_Active",
                table: "Sessions",
                column: "StationId",
                unique: true,
                filter: "\"EndedAt\" IS NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Sessions_StationId_Active",
                table: "Sessions");

            migrationBuilder.CreateIndex(
                name: "IX_Sessions_StationId",
                table: "Sessions",
                column: "StationId");
        }
    }
}

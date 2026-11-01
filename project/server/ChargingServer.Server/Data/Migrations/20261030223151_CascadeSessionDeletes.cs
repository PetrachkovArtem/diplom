using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ChargingServer.Server.Data.Migrations
{
    /// <inheritdoc />
    public partial class CascadeSessionDeletes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Sessions_Connectors_ConnectorId",
                table: "Sessions");

            migrationBuilder.DropForeignKey(
                name: "FK_Sessions_Stations_StationId",
                table: "Sessions");

            migrationBuilder.AddForeignKey(
                name: "FK_Sessions_Connectors_ConnectorId",
                table: "Sessions",
                column: "ConnectorId",
                principalTable: "Connectors",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Sessions_Stations_StationId",
                table: "Sessions",
                column: "StationId",
                principalTable: "Stations",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Sessions_Connectors_ConnectorId",
                table: "Sessions");

            migrationBuilder.DropForeignKey(
                name: "FK_Sessions_Stations_StationId",
                table: "Sessions");

            migrationBuilder.AddForeignKey(
                name: "FK_Sessions_Connectors_ConnectorId",
                table: "Sessions",
                column: "ConnectorId",
                principalTable: "Connectors",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Sessions_Stations_StationId",
                table: "Sessions",
                column: "StationId",
                principalTable: "Stations",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}

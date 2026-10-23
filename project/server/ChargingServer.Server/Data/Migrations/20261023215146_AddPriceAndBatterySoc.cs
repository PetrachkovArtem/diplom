using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ChargingServer.Server.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddPriceAndBatterySoc : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "BatterySoc",
                table: "Sessions",
                type: "numeric",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "PricePerKwh",
                table: "Sessions",
                type: "numeric",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "PricePerKwh",
                table: "Accounts",
                type: "numeric",
                nullable: false,
                defaultValue: 0m);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BatterySoc",
                table: "Sessions");

            migrationBuilder.DropColumn(
                name: "PricePerKwh",
                table: "Sessions");

            migrationBuilder.DropColumn(
                name: "PricePerKwh",
                table: "Accounts");
        }
    }
}

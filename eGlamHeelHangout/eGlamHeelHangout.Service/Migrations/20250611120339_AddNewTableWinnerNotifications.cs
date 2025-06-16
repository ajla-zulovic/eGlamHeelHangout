using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eGlamHeelHangout.Service.Migrations
{
    public partial class AddNewTableWinnerNotifications : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "GiveawayParticipants",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "City",
                table: "GiveawayParticipants",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PostalCode",
                table: "GiveawayParticipants",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "WinnerNotifications",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    GiveawayId = table.Column<int>(type: "int", nullable: false),
                    GiveawayTitle = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    WinnerUserId = table.Column<int>(type: "int", nullable: false),
                    WinnerUsername = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NotificationDate = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WinnerNotifications", x => x.Id);
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "WinnerNotifications");

            migrationBuilder.DropColumn(
                name: "Address",
                table: "GiveawayParticipants");

            migrationBuilder.DropColumn(
                name: "City",
                table: "GiveawayParticipants");

            migrationBuilder.DropColumn(
                name: "PostalCode",
                table: "GiveawayParticipants");
        }
    }
}

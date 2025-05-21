using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eGlamHeelHangout.Service.Migrations
{
    public partial class AddIsWinnerAtributteGiveawayParticipants : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsWinner",
                table: "GiveawayParticipants",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsWinner",
                table: "GiveawayParticipants");
        }
    }
}

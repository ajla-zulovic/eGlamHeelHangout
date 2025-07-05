using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eGlamHeelHangout.Service.Migrations
{
    public partial class ForeignKeyWinnerNotification : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
           

            migrationBuilder.CreateIndex(
                name: "IX_WinnerNotifications_GiveawayId",
                table: "WinnerNotifications",
                column: "GiveawayId");

            migrationBuilder.CreateIndex(
                name: "IX_WinnerNotifications_WinnerUserId",
                table: "WinnerNotifications",
                column: "WinnerUserId");


            migrationBuilder.AddForeignKey(
                name: "FK_WinnerNotifications_Giveaways_GiveawayId",
                table: "WinnerNotifications",
                column: "GiveawayId",
                principalTable: "Giveaways",
                principalColumn: "GiveawayID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_WinnerNotifications_Users_WinnerUserId",
                table: "WinnerNotifications",
                column: "WinnerUserId",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.Cascade);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
          

            migrationBuilder.DropForeignKey(
                name: "FK_WinnerNotifications_Giveaways_GiveawayId",
                table: "WinnerNotifications");

            migrationBuilder.DropForeignKey(
                name: "FK_WinnerNotifications_Users_WinnerUserId",
                table: "WinnerNotifications");

            migrationBuilder.DropIndex(
                name: "IX_WinnerNotifications_GiveawayId",
                table: "WinnerNotifications");

            migrationBuilder.DropIndex(
                name: "IX_WinnerNotifications_WinnerUserId",
                table: "WinnerNotifications");

        }
    }
}

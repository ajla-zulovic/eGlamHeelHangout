using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eGlamHeelHangout.Service.Migrations
{
    public partial class ChangedNotificationAndUserRoleEntity : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_UsersRoles",
                table: "UsersRoles");

            migrationBuilder.DropColumn(
                name: "UserRoleId",
                table: "UsersRoles");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UsersRoles",
                table: "UsersRoles",
                columns: new[] { "UserId", "RoleId" });

            migrationBuilder.AddColumn<int>(
                name: "GiveawayId",
                table: "Notifications",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ProductId",
                table: "Notifications",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_GiveawayId",
                table: "Notifications",
                column: "GiveawayId");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_ProductId",
                table: "Notifications",
                column: "ProductId");

            migrationBuilder.AddForeignKey(
                name: "FK_Notifications_Giveaways_GiveawayId",
                table: "Notifications",
                column: "GiveawayId",
                principalTable: "Giveaways",
                principalColumn: "GiveawayID");

            migrationBuilder.AddForeignKey(
                name: "FK_Notifications_Products_ProductId",
                table: "Notifications",
                column: "ProductId",
                principalTable: "Products",
                principalColumn: "ProductID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
       name: "FK_Notifications_Giveaways_GiveawayId",
       table: "Notifications");

            migrationBuilder.DropForeignKey(
                name: "FK_Notifications_Products_ProductId",
                table: "Notifications");

            migrationBuilder.DropIndex(
                name: "IX_Notifications_GiveawayId",
                table: "Notifications");

            migrationBuilder.DropIndex(
                name: "IX_Notifications_ProductId",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "GiveawayId",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "ProductId",
                table: "Notifications");

            migrationBuilder.DropPrimaryKey(
                name: "PK_UsersRoles",
                table: "UsersRoles");

            migrationBuilder.AddColumn<int>(
                name: "UserRoleId",
                table: "UsersRoles",
                type: "int",
                nullable: false,
                defaultValue: 0)
                .Annotation("SqlServer:Identity", "1, 1");

            migrationBuilder.AddPrimaryKey(
                name: "PK_UsersRoles",
                table: "UsersRoles",
                column: "UserRoleId");
        }
    }
}

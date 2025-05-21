using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eGlamHeelHangout.Service.Migrations
{
    public partial class ChangedGiveawayandGiveawayParticipant : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Giveaways_Products",
                table: "Giveaways");

            migrationBuilder.DropForeignKey(
                name: "FK_Giveaways_Users",
                table: "Giveaways");

            migrationBuilder.DropColumn(
                name: "StartDate",
                table: "Giveaways");

            migrationBuilder.DropColumn(
                name: "DateJoined",
                table: "GiveawayParticipants");

            migrationBuilder.DropColumn(
                name: "ProductID",
                table: "Giveaways");

            migrationBuilder.DropColumn(
                name: "WinnerUserID",
                table: "Giveaways");

            migrationBuilder.AddColumn<string>(
                name: "Color",
                table: "Giveaways",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "Giveaways",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "HeelHeight",
                table: "Giveaways",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<bool>(
                name: "IsClosed",
                table: "Giveaways",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Title",
                table: "Giveaways",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

          
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Giveaways_Products_ProductId",
                table: "Giveaways");

            migrationBuilder.DropForeignKey(
                name: "FK_Giveaways_Users_UserId",
                table: "Giveaways");

            migrationBuilder.DropColumn(
                name: "Color",
                table: "Giveaways");

            migrationBuilder.DropColumn(
                name: "Description",
                table: "Giveaways");

            migrationBuilder.DropColumn(
                name: "HeelHeight",
                table: "Giveaways");

            migrationBuilder.DropColumn(
                name: "IsClosed",
                table: "Giveaways");

            migrationBuilder.DropColumn(
                name: "Title",
                table: "Giveaways");


            migrationBuilder.AddColumn<int>(
                 name: "ProductID",
                 table: "Giveaways",
                 type: "int",
                 nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "WinnerUserID",
                table: "Giveaways",
                type: "int",
                nullable: true);


            migrationBuilder.AddColumn<DateTime>(
                name: "StartDate",
                table: "Giveaways",
                type: "datetime",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "DateJoined",
                table: "GiveawayParticipants",
                type: "datetime",
                nullable: true,
                defaultValueSql: "(getdate())");

            migrationBuilder.AddForeignKey(
                name: "FK_Giveaways_Products",
                table: "Giveaways",
                column: "ProductID",
                principalTable: "Products",
                principalColumn: "ProductID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Giveaways_Users",
                table: "Giveaways",
                column: "WinnerUserID",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.SetNull);
        }
    }
}

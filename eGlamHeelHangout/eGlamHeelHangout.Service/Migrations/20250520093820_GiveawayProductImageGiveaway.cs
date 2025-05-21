using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eGlamHeelHangout.Service.Migrations
{
    public partial class GiveawayProductImageGiveaway : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<byte[]>(
                name: "GiveawayProductImage",
                table: "Giveaways",
                type: "varbinary(max)",
                nullable: false,
                defaultValue: new byte[0]);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "GiveawayProductImage",
                table: "Giveaways");
        }
    }
}

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eGlamHeelHangout.Service.Migrations
{
    public partial class AddForeignKeyToOrderItemTable : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ProductSizeId",
                table: "OrderItems",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_ProductSizeId",
                table: "OrderItems",
                column: "ProductSizeId");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderItems_ProductSizes_ProductSizeId",
                table: "OrderItems",
                column: "ProductSizeId",
                principalTable: "ProductSizes",
                principalColumn: "ProductSizeID",
                //onDelete: ReferentialAction.Cascade);
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_OrderItems_ProductSizes_ProductSizeId",
                table: "OrderItems");

            migrationBuilder.DropIndex(
                name: "IX_OrderItems_ProductSizeId",
                table: "OrderItems");

            migrationBuilder.DropColumn(
                name: "ProductSizeId",
                table: "OrderItems");
        }
    }
}

using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace IdeaPool.Migrations
{
    /// <inheritdoc />
    public partial class AddProfileFeatures : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "AvatarUrl",
                table: "Users",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "UserFavoriteIdeas",
                columns: table => new
                {
                    FavoriteIdeasId = table.Column<int>(type: "integer", nullable: false),
                    FavoritedByUsersId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserFavoriteIdeas", x => new { x.FavoriteIdeasId, x.FavoritedByUsersId });
                    table.ForeignKey(
                        name: "FK_UserFavoriteIdeas_Ideas_FavoriteIdeasId",
                        column: x => x.FavoriteIdeasId,
                        principalTable: "Ideas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserFavoriteIdeas_Users_FavoritedByUsersId",
                        column: x => x.FavoritedByUsersId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_UserFavoriteIdeas_FavoritedByUsersId",
                table: "UserFavoriteIdeas",
                column: "FavoritedByUsersId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserFavoriteIdeas");

            migrationBuilder.DropColumn(
                name: "AvatarUrl",
                table: "Users");
        }
    }
}

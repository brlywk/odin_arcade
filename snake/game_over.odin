package main
import "core:fmt"
import rl "vendor:raylib"

GAME_OVER_SIZE :: 42
GAME_OVER_SCORE_SIZE :: 32
GAME_OVER_RESTART_SIZE :: 24
GAME_OVER_PADDING :: 16

GAME_OVER_COLOR :: rl.BLACK

game_over_update :: proc(game: ^Game) {
	if rl.IsKeyPressed(rl.KeyboardKey.R) {
		game_reset(game)
	}
}

game_over_draw :: proc(game: ^Game) {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(BG_COLOR)

	y_start: i32 =
		WIN_H / 2 -
		(GAME_OVER_SIZE + GAME_OVER_RESTART_SIZE + GAME_OVER_SCORE_SIZE + 2 * GAME_OVER_PADDING) /
			2

	// game over text
	game_over_text: cstring = game.won ? "You won!" : "Game Over"
	_draw_text_centered_x(game_over_text, GAME_OVER_SIZE, y_start, GAME_OVER_COLOR)

	// score
	score_text := fmt.ctprintf("Your final score: %d", game.score)
	y_score := y_start + GAME_OVER_SIZE + GAME_OVER_PADDING
	_draw_text_centered_x(score_text, GAME_OVER_SCORE_SIZE, y_score, GAME_OVER_COLOR)

	// restart
	y_restart := y_score + GAME_OVER_SCORE_SIZE + GAME_OVER_PADDING
	_draw_text_centered_x(
		"Press 'R' to restart or Escape to quit.",
		GAME_OVER_RESTART_SIZE,
		y_restart,
		GAME_OVER_COLOR,
	)
}

_draw_text_centered_x :: proc(text: cstring, font_size: i32, y: i32, color: rl.Color) {
	text_width := rl.MeasureText(text, font_size)

	x := WIN_W / 2 - text_width / 2
	rl.DrawText(text, x, y, font_size, color)
}


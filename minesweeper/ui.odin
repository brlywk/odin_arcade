package main

import "core:fmt"
import rl "vendor:raylib"

ui_draw :: proc(game: ^Game) {
	// time
	time_elapsed := ui_format_time_elapsed(game.elapsed_time)
	time_text := fmt.ctprintf("Time: %s", time_elapsed)
	rl.DrawText(time_text, WINDOW_PADDING, WINDOW_PADDING, UI_FONT_SIZE, rl.BLACK)

	// mines
	mine_text := fmt.ctprintf("Mines: %d", game.field.mines)
	mine_text_w := rl.MeasureText(mine_text, UI_FONT_SIZE)
	rl.DrawText(
		mine_text,
		WINDOW_WIDTH - WINDOW_PADDING - mine_text_w,
		WINDOW_PADDING,
		UI_FONT_SIZE,
		rl.BLACK,
	)

}

ui_update :: proc(game: ^Game) {
	//
}

////////////////////////////////////////////////////////////////////////////////
// Helper
////////////////////////////////////////////////////////////////////////////////

ui_format_time_elapsed :: proc(seconds_elapsed: f64) -> string {
	total_seconds := int(seconds_elapsed)
	minutes := total_seconds / 60
	seconds := total_seconds % 60

	return fmt.tprintf("%02d:%02d", minutes, seconds)
}


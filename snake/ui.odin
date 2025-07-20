package main

import "core:fmt"
import rl "vendor:raylib"

//
// Constants
//

UI_PADDING :: 16

SCORE_TEXT_SIZE :: 24

ui_draw_score :: proc(game: Game) {
	score_text := fmt.ctprintf("Score: %d", game.score)
	score_text_w := rl.MeasureText(score_text, SCORE_TEXT_SIZE)
	rl.DrawText(score_text, WIN_W / 2 - score_text_w / 2, UI_PADDING, SCORE_TEXT_SIZE, rl.BLACK)
}


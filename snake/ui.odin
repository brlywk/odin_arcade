package main

import "core:fmt"
import rl "vendor:raylib"

//
// Constants
//

UI_PADDING :: 16

SCORE_TEXT_SIZE :: 24

GAME_FIELD_SIZE :: 640
GAME_FIELD_POS_X :: UI_PADDING
GAME_FIELD_POS_Y :: SCORE_TEXT_SIZE + 2 * UI_PADDING
GAME_FIELD_BG_COLOR :: rl.WHITE
GAME_FIELD_BORDER_COLOR :: rl.BLACK
GAME_FIELD_BORDER_SIZE :: 4

GAME_FIELD :: Rect {
	x      = GAME_FIELD_POS_X,
	y      = GAME_FIELD_POS_Y,
	width  = GAME_FIELD_SIZE,
	height = GAME_FIELD_SIZE,
}

ui_draw_score :: proc(data: Game_Data) {
	score_text := fmt.ctprintf("Score: %d", data.score)
	score_text_w := rl.MeasureText(score_text, SCORE_TEXT_SIZE)
	rl.DrawText(score_text, WIN_W / 2 - score_text_w / 2, UI_PADDING, SCORE_TEXT_SIZE, rl.BLACK)
}

ui_draw_field_bg :: proc() {
	rl.DrawRectangleRec(GAME_FIELD, GAME_FIELD_BG_COLOR)
}

ui_draw_field_border :: proc() {
	rl.DrawRectangleLinesEx(GAME_FIELD, GAME_FIELD_BORDER_SIZE, GAME_FIELD_BORDER_COLOR)
}

pos_in_field :: proc(pos: Vec2) -> Vec2 {
	return Vec2{pos.x + GAME_FIELD.x, pos.y + GAME_FIELD.y}
}


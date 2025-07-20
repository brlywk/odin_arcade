package main

import "core:math/rand"
import rl "vendor:raylib"

//
// Constants
//

GAME_FIELD_SIZE :: 640
GAME_FIELD_POS_X :: UI_PADDING + GAME_FIELD_BORDER_SIZE
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

// number of horizontal / vertical grid fields
GAME_GRID_NUM :: GAME_FIELD_SIZE / PLAYER_SEGMENT_SIZE


// Returns the position translated to an "in game field" position.
field_pos :: proc(pos: Vec2) -> Vec2 {
	return Vec2{pos.x + GAME_FIELD.x, pos.y + GAME_FIELD.y}
}

field_center :: proc() -> Vec2 {
	center_x := GAME_FIELD.x + GAME_FIELD_SIZE / 2
	center_y := GAME_FIELD.y + GAME_FIELD_SIZE / 2

	// float and int math is so awesome that we have to do just a perfectly sane amount of grid snapping...
	grid_x := f32(int(center_x / PLAYER_SEGMENT_SIZE)) * PLAYER_SEGMENT_SIZE - PLAYER_SEGMENT_SIZE
	grid_y := f32(int(center_y / PLAYER_SEGMENT_SIZE)) * PLAYER_SEGMENT_SIZE - PLAYER_SEGMENT_SIZE

	return Vec2{grid_x, grid_y}
}

valid_move :: proc(to: Vec2) -> bool {
	valid_x :=
		to.x >= GAME_FIELD.x && to.x + PLAYER_SEGMENT_SIZE <= GAME_FIELD.x + GAME_FIELD.width
	valid_y :=
		to.y >= GAME_FIELD.y && to.y + PLAYER_SEGMENT_SIZE <= GAME_FIELD.y + GAME_FIELD.height

	return valid_x && valid_y
}

field_draw_bg :: proc() {
	rl.DrawRectangleRec(GAME_FIELD, GAME_FIELD_BG_COLOR)
}

field_draw_border :: proc() {
	field := GAME_FIELD
	field.x -= GAME_FIELD_BORDER_SIZE
	field.y -= GAME_FIELD_BORDER_SIZE
	field.width += 2 * GAME_FIELD_BORDER_SIZE
	field.height += 2 * GAME_FIELD_BORDER_SIZE

	rl.DrawRectangleLinesEx(field, GAME_FIELD_BORDER_SIZE, GAME_FIELD_BORDER_COLOR)
}

field_random_pos :: proc() -> Vec2 {
	grid_x := rand.int_max(GAME_GRID_NUM)
	grid_y := rand.int_max(GAME_GRID_NUM)

	spawn_at_x := GAME_FIELD.x + f32(grid_x) * PLAYER_SEGMENT_SIZE
	spawn_at_y := GAME_FIELD.y + f32(grid_y) * PLAYER_SEGMENT_SIZE

	return {spawn_at_x, spawn_at_y}
}


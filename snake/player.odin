package main

import rl "vendor:raylib"

//
// Constants
//

PLAYER_COLOR :: rl.SKYBLUE
PLAYER_SEGMENT_SIZE :: 32

Direction :: enum {
	Up,
	Down,
	Left,
	Right,
}

Player :: struct {
	using rect: Rect,
	segments:   u32,
	direction:  Direction, // player movement direction
}

player_new :: proc(start_pos: Vec2 = {0, 0}) -> Player {
	start_pos_in_field := pos_in_field(start_pos)

	return Player {
		rect = Rect {
			x = start_pos_in_field.x,
			y = start_pos_in_field.y,
			width = PLAYER_SEGMENT_SIZE,
			height = PLAYER_SEGMENT_SIZE,
		},
		segments = 1,
	}
}

player_draw :: proc(player: Player) {
	rl.DrawRectangleRec(player.rect, PLAYER_COLOR)
}


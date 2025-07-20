package main

import "core:log"
import "core:math/rand"
import "core:testing"
import rl "vendor:raylib"

//
// Constants
//

PLAYER_COLOR :: rl.SKYBLUE
PLAYER_EYE_COLOR :: rl.BLACK
PLAYER_EYE_RADIUS :: 2.0
PLAYER_EYE_PADDING :: i32(PLAYER_EYE_RADIUS * 3)
PLAYER_SEGMENT_SIZE :: 32

Direction :: enum {
	Up,
	Down,
	Left,
	Right,
}

Player :: struct {
	using rect:       Rect,
	segments:         [dynamic]Vec2,
	direction:        Direction, // current player movement direction
	queued_direction: Direction, // next player movement direction
}

player_new :: proc(start_pos: Vec2 = {0, 0}) -> Player {
	head := field_pos(start_pos)
	start_dir := rand.choice_enum(Direction)
	segments := make([dynamic]Vec2, 0, GAME_GRID_NUM * GAME_GRID_NUM)

	return Player {
		rect = Rect {
			x = head.x,
			y = head.y,
			width = PLAYER_SEGMENT_SIZE,
			height = PLAYER_SEGMENT_SIZE,
		},
		direction = start_dir,
		queued_direction = start_dir,
		segments = segments,
	}
}


player_draw :: proc(player: Player) {
	// draw the head of the snake
	_player_draw_head(player)

	// draw all of the segments
	for s in player.segments {
		// s is a position Vec2
		s_rect := Rect{s.x, s.y, PLAYER_SEGMENT_SIZE, PLAYER_SEGMENT_SIZE}
		rl.DrawRectangleRec(s_rect, PLAYER_COLOR)
	}
}

// Returns the position the player will move to next based on current direction.
player_next_move :: proc(player: ^Player) -> Vec2 {
	player.direction = player.queued_direction
	return _player_head(player) + (_player_direction_vec(player) * PLAYER_SEGMENT_SIZE)
}

player_queue_input :: proc(player: ^Player) {
	#partial switch rl.GetKeyPressed() {
	case rl.KeyboardKey.UP, rl.KeyboardKey.W:
		player.queued_direction = .Up
	case rl.KeyboardKey.DOWN, rl.KeyboardKey.S:
		player.queued_direction = .Down
	case rl.KeyboardKey.LEFT, rl.KeyboardKey.A:
		player.queued_direction = .Left
	case rl.KeyboardKey.RIGHT, rl.KeyboardKey.D:
		player.queued_direction = .Right
	}
}

// Assume that there is only one food item on the field at any given time, for simplicities sake.
player_move :: proc(player: ^Player, can_move: bool) {
	if !can_move do return

	new_head := player_next_move(player)
	_player_update_segments(player)
	_player_update_head(player, new_head)
}


player_reset :: proc(player: ^Player, start_pos: Vec2 = {0, 0}) {
	clear(&player.segments)

	head := field_pos(start_pos)
	append(&player.segments, head)

	player.direction = rand.choice_enum(Direction)
	player.rect = {head.x, head.y, PLAYER_SEGMENT_SIZE, PLAYER_SEGMENT_SIZE}
}

player_occupies_field :: proc(player: ^Player, pos: Vec2) -> bool {
	if _player_head(player) == pos do return true

	for s in player.segments do if s == pos {
		return true
	}

	return false
}

player_delete :: proc(player: ^Player) {
	delete(player.segments)
	player.segments = nil
}

//
// "internal" methods (don't call outside player.odin! seriously, don't!)
//

_player_head :: proc(player: ^Player) -> Vec2 {
	return rect_get_position_vec2(player)
}

_player_update_head :: proc(player: ^Player, new_pos: Vec2) {
	player.x = new_pos.x
	player.y = new_pos.y
}

_player_draw_head :: proc(player: Player) {
	// head
	rl.DrawRectangleRec(player.rect, PLAYER_COLOR)

	px := i32(player.x)
	py := i32(player.y)

	// eyes looking into the right direction
	e1: [2]i32
	e2: [2]i32

	switch player.direction {
	case .Up:
		e1.x = px + PLAYER_EYE_PADDING
		e1.y = py + PLAYER_EYE_PADDING

		e2.x = px + PLAYER_SEGMENT_SIZE - PLAYER_EYE_PADDING
		e2.y = py + PLAYER_EYE_PADDING

	case .Down:
		e1.x = px + PLAYER_EYE_PADDING
		e1.y = py + PLAYER_SEGMENT_SIZE - PLAYER_EYE_PADDING

		e2.x = px + PLAYER_SEGMENT_SIZE - PLAYER_EYE_PADDING
		e2.y = py + PLAYER_SEGMENT_SIZE - PLAYER_EYE_PADDING

	case .Left:
		e1.x = px + PLAYER_EYE_PADDING
		e1.y = py + PLAYER_EYE_PADDING

		e2.x = px + PLAYER_EYE_PADDING
		e2.y = py + PLAYER_SEGMENT_SIZE - PLAYER_EYE_PADDING

	case .Right:
		e1.x = px + PLAYER_SEGMENT_SIZE - PLAYER_EYE_PADDING
		e1.y = py + PLAYER_EYE_PADDING

		e2.x = px + PLAYER_SEGMENT_SIZE - PLAYER_EYE_PADDING
		e2.y = py + PLAYER_SEGMENT_SIZE - PLAYER_EYE_PADDING
	}

	// draw eyes
	rl.DrawCircle(e1.x, e1.y, PLAYER_EYE_RADIUS, PLAYER_EYE_COLOR)
	rl.DrawCircle(e2.x, e2.y, PLAYER_EYE_RADIUS, PLAYER_EYE_COLOR)
}

_player_direction_vec :: proc(player: ^Player) -> Vec2 {
	switch player.direction {
	case .Up:
		return {0.0, -1.0}
	case .Left:
		return {-1.0, 0.0}
	case .Right:
		return {1.0, 0.0}
	case .Down:
		return {0.0, 1.0}

	case:
		return {0.0, 0.0}
	}
}

_player_add_segment :: proc(player: ^Player) {
	head := _player_head(player)
	inject_at(&player.segments, 0, head)
}

// Cascade position updates to the player through all segments.
//
// Note: This is a helper for movement, not the full movement logic (no collision checking)!
_player_update_segments :: proc(player: ^Player) {
	if len(player.segments) == 0 do return

	prev := _player_head(player)
	curr := player.segments[0]
	for i in 0 ..< len(player.segments) {
		curr = player.segments[i]
		player.segments[i] = prev
		prev = curr
	}
}

@(test)
test_player_update_segments :: proc(t: ^testing.T) {
	player := player_new()
	defer player_delete(&player)

	// i = 0
	append(&player.segments, Vec2{10, 10})
	// i = 1
	append(&player.segments, Vec2{20, 20})
	// i = 2
	append(&player.segments, Vec2{30, 30})

	_player_update_segments(&player)
	log.info("segments", player.segments)

	// the "head" of the snake starts at {20,56}, b/c we translate {0,0} to
	// "in game field" coordinates with player_new
	testing.expect_value(t, player.segments[0], Vec2{20, 56})
	testing.expect_value(t, player.segments[1], Vec2{10, 10})
	testing.expect_value(t, player.segments[2], Vec2{20, 20})
}


package main

import "base:runtime"
import "core:log"
import "core:math/rand"
import "core:mem"
import "core:time"
import rl "vendor:raylib"

//
// Convenience Types
//

Vec2 :: rl.Vector2
Rect :: rl.Rectangle

//
// Constants
// 

WIN_W :: GAME_FIELD_SIZE + 2 * UI_PADDING
WIN_H :: GAME_FIELD_POS_Y + GAME_FIELD_SIZE + UI_PADDING
WIN_CENTER :: Vec2{WIN_W / 2, WIN_H / 2}

BG_COLOR :: rl.LIGHTGRAY

main :: proc() {
	when ODIN_DEBUG {
		// tracking allocator for learning purposes
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		// defer mem.tracking_allocator_destroy(&track) - see comment below
		context.allocator = mem.tracking_allocator(&track)
		defer check_tracking_allocator(&track, true) // use helper to destroy allocator
	}
	// set up logger
	context.logger = log.create_console_logger()
	defer log.destroy_console_logger(context.logger)

	// set up rng
	seed := time.time_to_unix_nano(time.now())
	random_state := rand.create(u64(seed))
	context.random_generator = runtime.default_random_generator(&random_state)

	// set up window
	rl.InitWindow(WIN_W, WIN_H, "Sneck")
	defer rl.CloseWindow()

	// set up entities
	data := Game_Data{}
	player := player_new(WIN_CENTER - PLAYER_SEGMENT_SIZE)
	log.info("Game Data", data)

	for !rl.WindowShouldClose() {
		// DRAW
		rl.BeginDrawing()
		defer rl.EndDrawing()

		// background
		rl.ClearBackground(BG_COLOR)

		// game field
		ui_draw_field_bg()

		// draw player
		player_draw(player)

		// draw field border
		ui_draw_field_border()

		// UI
		ui_draw_score(data)
	}
}

//
// Utilities
//

// Returns width and height for the given rl.Rectange rect.
get_size :: proc(rect: Rect) -> (width, height: f32) {
	return rect.width, rect.height
}

// Returns x and y for the given rl.Rectangle rect.
get_position :: proc(rect: Rect) -> (x, y: f32) {
	return rect.x, rect.y
}


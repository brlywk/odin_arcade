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

WIN_W :: GAME_FIELD_SIZE + 2 * UI_PADDING + 2 * GAME_FIELD_BORDER_SIZE
WIN_H :: GAME_FIELD_POS_Y + GAME_FIELD_SIZE + UI_PADDING + GAME_FIELD_BORDER_SIZE
WIN_CENTER :: Vec2{WIN_W / 2, WIN_H / 2}

GAME_STEP_SPEED :: 0.8

BG_COLOR :: rl.LIGHTGRAY

main :: proc() {
	log_level := log.Level.Warning

	when ODIN_DEBUG {
		// tracking allocator for learning purposes
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		// defer mem.tracking_allocator_destroy(&track) - see comment below
		context.allocator = mem.tracking_allocator(&track)
		defer check_tracking_allocator(&track, true) // use helper to destroy allocator

		log_level = log.Level.Debug
	}
	// set up logger
	context.logger = log.create_console_logger(log_level)
	defer log.destroy_console_logger(context.logger)

	// set up rng
	seed := time.time_to_unix_nano(time.now())
	random_state := rand.create(u64(seed))
	context.random_generator = runtime.default_random_generator(&random_state)

	// set up window
	rl.InitWindow(WIN_W, WIN_H, "Sneck")
	defer rl.CloseWindow()

	player := player_new(field_center())
	game := game_new(player, GAME_STEP_SPEED)
	defer game_destroy(&game)
	game_init(&game)

	log.debug("Game Data", game)

	for !rl.WindowShouldClose() {
		// UPDATE
		game_update(&game)

		// DRAW
		game_draw(&game)
	}
}


package main

import "base:runtime"
import "core:log"
import "core:math/rand"
import "core:mem"
import "core:time"
import rl "vendor:raylib"

main :: proc() {
	// DEBUG
	//
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer check_tracking_allocator(&track, true)
	}

	// LOGGING
	//
	log_level := log.Level.Debug when ODIN_DEBUG else log.Level.Fatal
	context.logger = log.create_console_logger(log_level)
	defer log.destroy_console_logger(context.logger)

	// RNG
	//
	seed := time.time_to_unix_nano(time.now())
	random_state := rand.create(u64(seed))
	context.random_generator = runtime.default_random_generator(&random_state)

	// GAME STATE
	//
	game := game_create()
	defer game_destroy(&game)

	// RAYLIB
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Minesweeper")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)
	rl.SetWindowState({.VSYNC_HINT})
	// rl.SetExitKey(.KEY_NULL)

	// GAME LOOP
	//
	for !rl.WindowShouldClose() {
		defer free_all(context.temp_allocator)

		// UPDATE
		//
		game_update(&game)

		// DRAW
		//
		rl.BeginDrawing()

		rl.ClearBackground(WINDOW_BG)
		game_draw(&game)

		rl.EndDrawing()
	}
}


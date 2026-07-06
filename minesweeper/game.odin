package main

import "core:time"
import rl "vendor:raylib"

Difficulty :: enum {
	Easy,
	Medium,
	Hard,
}

State :: enum {
	DifficultySelection,
	Playing,
}

Game :: struct {
	state:             State,
	difficulty:        Difficulty,
	field_bounds:      rl.Rectangle,
	field:             Field,
	field_created:     bool,
	field_initialized: bool,
	over:              bool,
	won:               bool,
	start_time:        time.Time,
	elapsed_time:      f64,
}

////////////////////////////////////////////////////////////////////////////////
// Create, Reset, DESTROY
////////////////////////////////////////////////////////////////////////////////

game_create :: proc() -> Game {
	return {state = .DifficultySelection}
}

game_init_playing :: proc(game: ^Game, allocator := context.allocator) {
	if game.field_created do return

	field_settings := GAME_DIFFICULTY_FIELD_SETTINGS[game.difficulty]

	// Calculate field bounds to fit available space with square cells
	header_height: f32 = 40.0
	available_width: f32 = f32(WINDOW_WIDTH) - 2 * WINDOW_PADDING
	available_height: f32 = f32(WINDOW_HEIGHT) - header_height - 2 * WINDOW_PADDING

	cell_size_w := available_width / f32(field_settings.cols)
	cell_size_h := available_height / f32(field_settings.rows)
	cs := min(cell_size_w, cell_size_h)

	field_width := cs * f32(field_settings.cols)
	field_height := cs * f32(field_settings.rows)

	game.field_bounds = rl.Rectangle {
		x      = WINDOW_PADDING + (available_width - field_width) / 2,
		y      = WINDOW_PADDING + header_height + (available_height - field_height) / 2,
		width  = field_width,
		height = field_height,
	}

	game.field = field_create(field_settings, game.field_bounds, allocator)
	game.field_created = true
	game.start_time = time.now()
}

game_destroy :: proc(game: ^Game) {
	if game.field_created {
		field_destroy(&game.field)
		game.field_created = false
	}
}

game_reset :: proc(game: ^Game) {
	game_destroy(game)
	game.field_created = false
	game.field_initialized = false
	game.over = false
	game.won = false
	game.elapsed_time = 0
	game.start_time = time.now()
	game_init_playing(game)
}

game_return_to_menu :: proc(game: ^Game) {
	game_destroy(game)
	game.field_created = false
	game.field_initialized = false
	game.over = false
	game.won = false
	game.elapsed_time = 0
	game.state = .DifficultySelection
}

////////////////////////////////////////////////////////////////////////////////
// Update functions
////////////////////////////////////////////////////////////////////////////////

game_update :: proc(game: ^Game) {
	switch game.state {
	case .DifficultySelection:
		game_update_difficulty_selection(game)
	case .Playing:
		game_update_playing(game)
	}
}

game_update_difficulty_selection :: proc(game: ^Game) {
	handle_difficulty_selection_input(game)
}

game_update_playing :: proc(game: ^Game, allocator := context.allocator) {
	if !game.over {
		now := time.now()
		game.elapsed_time = time.duration_seconds(time.diff(game.start_time, now))
	}

	game_init_playing(game, allocator)
	handle_game_playing_input(game)

	if game.over {
		if rl.IsKeyPressed(.R) {
			game_reset(game)
		}
		if rl.IsKeyPressed(.M) {
			game_return_to_menu(game)
		}
	} else {
		if rl.IsKeyPressed(.M) {
			game_return_to_menu(game)
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
// Draw functions
////////////////////////////////////////////////////////////////////////////////

game_draw :: proc(game: ^Game) {
	switch game.state {
	case .DifficultySelection:
		game_draw_difficulty_selection(game)
	case .Playing:
		game_draw_playing(game)
	}
}

game_draw_difficulty_selection :: proc(game: ^Game) {
	title_text := cstring("Select Difficulty")
	title_size :: 32
	title_w := rl.MeasureText(title_text, title_size)
	title_x := i32(WINDOW_WIDTH) / 2 - title_w / 2
	title_y := i32(WINDOW_HEIGHT) / 4
	rl.DrawText(title_text, title_x, title_y, title_size, rl.BLACK)

	button_width :: 200
	button_height :: 50
	button_spacing :: 20
	start_y := title_y + 80

	difficulties := [?]Difficulty{.Easy, .Medium, .Hard}
	mouse_pos := rl.GetMousePosition()

	for d, i in difficulties {
		rect := rl.Rectangle {
			x      = f32(WINDOW_WIDTH) / 2 - f32(button_width) / 2,
			y      = f32(start_y + i32(i * (button_height + button_spacing))),
			width  = button_width,
			height = button_height,
		}

		color := rl.LIGHTGRAY
		if rl.CheckCollisionPointRec(mouse_pos, rect) {
			color = rl.GRAY
		}

		rl.DrawRectangleRec(rect, color)
		rl.DrawRectangleLinesEx(rect, 2, rl.BLACK)

		text := difficulty_to_string(d)
		text_size :: 24
		text_w := rl.MeasureText(text, text_size)
		text_x := rect.x + rect.width / 2 - f32(text_w) / 2
		text_y := rect.y + rect.height / 2 - text_size / 2
		rl.DrawText(text, i32(text_x), i32(text_y), text_size, rl.BLACK)
	}
}

game_draw_playing :: proc(game: ^Game) {
	game_init_playing(game)
	field_draw(&game.field)
	ui_draw(game)

	if game.over {
		overlay_text := game.won ? cstring("You Win!") : cstring("Game Over!")
		sub_text := cstring("Press R to Restart or M for Menu")

		overlay_size :: 48
		sub_size :: 24

		overlay_w := rl.MeasureText(overlay_text, overlay_size)
		sub_w := rl.MeasureText(sub_text, sub_size)

		center_x := i32(WINDOW_WIDTH) / 2
		center_y := i32(WINDOW_HEIGHT) / 2

		rl.DrawRectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, rl.Color{0, 0, 0, 222})

		rl.DrawText(
			overlay_text,
			center_x - overlay_w / 2,
			center_y - 40,
			overlay_size,
			game.won ? rl.GREEN : rl.RED,
		)
		rl.DrawText(sub_text, center_x - sub_w / 2, center_y + 20, sub_size, rl.WHITE)
	}
}

////////////////////////////////////////////////////////////////////////////////
// Helper
////////////////////////////////////////////////////////////////////////////////

difficulty_to_string :: proc(difficulty: Difficulty) -> cstring {
	switch difficulty {
	case .Easy:
		return "Easy"
	case .Medium:
		return "Medium"
	case .Hard:
		return "Hard"
	}

	return "Unknown"
}

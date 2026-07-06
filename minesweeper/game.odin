package main

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
	field_created:     bool, // graphical setup based on difficulty etc.
	field_initialized: bool, // mines have been placed after first click etc.
}

////////////////////////////////////////////////////////////////////////////////
// Create, Reset, DESTROY
////////////////////////////////////////////////////////////////////////////////

game_create :: proc() -> Game {
	// TODO: placeholder, depends on "UI" atop field
	//
	// calculate bounds based on maximum height (due to "UI" on top)
	// but adjust bounds for the field to be centered horizontally in the end
	offset := rl.Vector2{0, 32.0}
	field_height := WINDOW_HEIGHT - offset.y - 2 * WINDOW_PADDING
	total_horizontal_padding := WINDOW_WIDTH - field_height

	field_bounds := rl.Rectangle {
		x      = total_horizontal_padding / 2.0,
		y      = WINDOW_PADDING + offset.y,
		width  = field_height,
		height = field_height,
	}


	// TODO: Maybe add an "uninitialized" state?
	return {state = .Playing, field_bounds = field_bounds}
}

game_init_playing :: proc(game: ^Game, allocator := context.allocator) {
	if game.field_created do return

	field_settings := GAME_DIFFICULTY_FIELD_SETTINGS[game.difficulty]
	game.field = field_create(field_settings, game.field_bounds, allocator)
	game.field_created = true
}

game_destroy :: proc(game: ^Game) {
	field_destroy(&game.field)
}

game_reset :: proc(game: ^Game) {
	//
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
	// handle input

	// once a selection has been made, we can actually init the game for playing
}

game_update_playing :: proc(game: ^Game, allocator := context.allocator) {
	// do an init of the field the first time we run this
	game_init_playing(game, allocator)

	// handle input
	handle_game_playing_input(game)
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
	rl.DrawText("Difficulty?!", WINDOW_PADDING, WINDOW_PADDING, 32.0, rl.BLACK)
}

game_draw_playing :: proc(game: ^Game) {
	field_draw(&game.field)
}

////////////////////////////////////////////////////////////////////////////////
// Helper
////////////////////////////////////////////////////////////////////////////////

difficulty_to_string :: proc(difficulty: Difficulty) -> string {
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


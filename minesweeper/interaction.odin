package main

import "core:fmt"
import rl "vendor:raylib"

handle_difficulty_selection_input :: proc(game: ^Game) {
	if !rl.IsMouseButtonPressed(.LEFT) do return

	mouse_pos := rl.GetMousePosition()

	button_width :: 200
	button_height :: 50
	button_spacing :: 20
	title_size :: 32
	title_y := i32(WINDOW_HEIGHT) / 4
	start_y := title_y + 80

	difficulties := [?]Difficulty{.Easy, .Medium, .Hard}

	for _, i in difficulties {
		rect := rl.Rectangle {
			x      = f32(WINDOW_WIDTH) / 2 - f32(button_width) / 2,
			y      = f32(start_y + i32(i * (button_height + button_spacing))),
			width  = button_width,
			height = button_height,
		}

		if rl.CheckCollisionPointRec(mouse_pos, rect) {
			game.difficulty = difficulties[i]
			game.state = .Playing
			game_init_playing(game)
			return
		}
	}
}


// Handles clicking on the playing field.
handle_game_playing_input :: proc(game: ^Game) {
	mouse_pos := rl.GetMousePosition()

	if game.over do return

	// reveal stuff
	if rl.IsMouseButtonPressed(.LEFT) {
		idx, valid := cell_at_index(mouse_pos, &game.field)
		cell, ok := field_get_cell_at(idx, &game.field)

		if !valid || !ok do return

		// first click should start the whole mine laying process
		if !game.field_initialized {
			field_place_mines(idx, &game.field)
			game.field_initialized = true

			// afterwards: for best game feel, the safezone around the first
			// click guarantees that we can do some floodfilling to uncover a
			// number of fields directly...
			flood_fill(idx, &game.field)
		}

		// actual interaction goes here...
		switch cell.kind {
		case .Safe:
			flood_fill(idx, &game.field)

			// win condition
			if field_all_non_mines_revealed(&game.field) {
				game.over = true
				game.won = true
				fmt.println("Game Over! You win!")
			}

		case .Mine:
			field_reveal_all(&game.field)
			game.over = true
			game.won = false
			fmt.println("Game Over! You lose!")
		}
	}

	// do the flag thingy
	if rl.IsMouseButtonPressed(.RIGHT) {
		idx, valid := cell_at_index(mouse_pos, &game.field)
		cell, ok := field_get_cell_at(idx, &game.field)

		if valid && ok {
			switch cell.state {
			case .Flagged:
				cell.state = .Concealed
			case .Concealed:
				cell.state = .Flagged
			case .Revealed:
				return
			}
		}
	}
}

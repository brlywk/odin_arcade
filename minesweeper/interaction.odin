package main

import "core:fmt"
import rl "vendor:raylib"

handle_difficulty_selection_input :: proc(game: ^Game) {
	mouse_pos := rl.GetMousePosition()
}


// Handles clicking on the playing field.
handle_game_playing_input :: proc(game: ^Game) {
	mouse_pos := rl.GetMousePosition()

	// reveal stuff
	if rl.IsMouseButtonPressed(.LEFT) {
		idx, valid := cell_at_index(mouse_pos, &game.field)
		cell, ok := field_get_cell_at(idx, &game.field)

		// first click should start the whole mine laying process
		if !game.field_initialized {
			// TODO: place mines...
			field_place_mines(idx, &game.field)
			game.field_initialized = true

			// afterwards: for best game feel, the safezone around the first
			// click guarantees that we can do some floodfilling to uncover a
			// number of fields directly...
		}

		if valid && ok {
			// DEBUG: Delete...
			fmt.printfln("Left Click at x=%f y=%f:\n\t%v ", mouse_pos.x, mouse_pos.y, cell)
			c, _ := cell_at(mouse_pos, &game.field)
			fmt.printfln("\tCoords: %v", c)
			fmt.printfln("\tIndex: %d", idx)
		}
	}

	// do the flag thingy
	if rl.IsMouseButtonPressed(.RIGHT) {
		idx, valid := cell_at_index(mouse_pos, &game.field)
		cell, ok := field_get_cell_at(idx, &game.field)

		if valid && ok {
			// DEBUG: Delete...
			fmt.printfln("Right Click at x=%f y=%f:\n\t%v ", mouse_pos.x, mouse_pos.y, cell)
			c, _ := cell_at(mouse_pos, &game.field)
			fmt.printfln("\tCoords: %v", c)

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


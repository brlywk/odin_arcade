package main

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

FieldSettings :: struct {
	cols:  u8,
	rows:  u8,
	mines: u8,
}

Field :: struct {
	cols:   u8,
	rows:   u8,
	mines:  u8,
	bounds: rl.Rectangle,
	grid:   [dynamic]Cell,
}

field_create :: proc(
	field_settings: FieldSettings,
	bounds: rl.Rectangle,
	allocator := context.allocator,
) -> Field {
	cell_count := int(field_settings.cols * field_settings.rows)

	return {
		cols = field_settings.cols,
		rows = field_settings.rows,
		mines = field_settings.mines,
		bounds = bounds,
		grid = make([dynamic]Cell, cell_count, allocator),
	}
}

field_destroy :: proc(field: ^Field) {
	delete(field.grid)
}

field_draw :: proc(field: ^Field) {
	// draw field itself...
	rl.DrawRectangleRec(field.bounds, FIELD_BG)
	rl.DrawRectangleLinesEx(
		{
			x = field.bounds.x - FIELD_BORDER_WITDH,
			y = field.bounds.y - FIELD_BORDER_WITDH,
			width = field.bounds.width + 2 * FIELD_BORDER_WITDH,
			height = field.bounds.height + 2 * FIELD_BORDER_WITDH,
		},
		FIELD_BORDER_WITDH,
		FIELD_BORDER_COLOR,
	)

	for cell, idx in field.grid {
		cell_draw(cell, idx, field)
	}
}

////////////////////////////////////////////////////////////////////////////////
// Placement, Uncovery etc.
////////////////////////////////////////////////////////////////////////////////

field_place_mines :: proc(initial_click_idx: int, field: ^Field) {
	// general approach:
	// - first click never is a mine, and therefore only after first click
	// placement is done
	// - create a safezone around first click with no mines
	// - place mines randomly in remaining coordinate candidates
	// - after mines are places, update all adjacent mine information on all
	// safe, not uncovered cells

	// safe zone is only the cells directly adjacent to the clicked cell
	// NOTE: Currently hard coded radius, maybe change this later
	safe_zone := field_get_safe_zone_cells(initial_click_idx, field, 1, context.temp_allocator)
	fmt.println("Safe indices:\n", safe_zone)
	safe_zone_set := make(map[int]struct{}, len(safe_zone), context.temp_allocator)
	for idx in safe_zone {
		safe_zone_set[idx] = {}
	}
	fmt.println("Safe set:", safe_zone_set)

	// all indices that are potential candidates for mines
	mine_candidate_indices := make([dynamic]int, context.temp_allocator)

	for _, idx in field.grid {
		_, safe := safe_zone_set[idx]
		if safe do continue
		append(&mine_candidate_indices, idx)
	}

	// shuffle candidate list...
	fmt.println("Mine candidates:", mine_candidate_indices[:])
	rand.shuffle(mine_candidate_indices[:])
	fmt.println("Mine candidates shuffled:", mine_candidate_indices[:])

	// ... and set the first n mine candidates to actually be a mine
	for m in mine_candidate_indices[:field.mines - 1] {
		cell, ok := field_get_cell_at(m, field)
		if !ok do panic("A mine candidate has no corresponding cell in the field grid")
		cell.kind = .Mine
	}

	// finally: update all cells with adjacent mine information now
	for &cell, idx in field.grid {
		mines := field_get_adjacent_mine_count(idx, field)
		cell.adjacent_mines = u8(mines)
	}

	when ODIN_DEBUG {
		fmt.println("Field:")
		for c in field.grid do fmt.println(c)
	}
}

////////////////////////////////////////////////////////////////////////////////
// Helper
////////////////////////////////////////////////////////////////////////////////


// Returns a pointer to the cell at `idx` in `field`.
field_get_cell_at :: proc(idx: int, field: ^Field) -> (^Cell, bool) {
	if idx < 0 || idx >= len(field.grid) do return nil, false
	return &field.grid[idx], true
}

// Returns all cell indices for a "safe zone" of `radius` cells around `idx`.
field_get_safe_zone_cells :: proc(
	idx: int,
	field: ^Field,
	radius: int,
	allocator := context.allocator,
) -> []int {
	cells := make([dynamic]int, allocator)

	coords := cell_from_index(idx, field.cols)
	col := int(coords.col)
	row := int(coords.row)

	for y := -radius; y <= radius; y += 1 {
		for x := -radius; x <= radius; x += 1 {
			// NOTE: we need to include `idx` as well, so we can have an easier
			// time checking all valid mine positions later...

			r := row + y
			c := col + x

			if r < 0 || r >= int(field.rows) || c < 0 || c >= int(field.cols) do continue

			append(&cells, r * int(field.cols) + c)
		}
	}

	return cells[:]
}

field_get_adjacent_mine_count :: proc(idx: int, field: ^Field) -> int {
	mine_count := 0

	adjacent := field_get_safe_zone_cells(idx, field, 1)
	defer delete(adjacent)

	for i in adjacent {
		// skip self
		if i == idx do continue

		cell := field.grid[i]
		if cell.kind == .Mine do mine_count += 1
	}

	return mine_count
}

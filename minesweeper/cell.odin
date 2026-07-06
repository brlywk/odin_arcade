package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

Coord :: struct {
	col: u8,
	row: u8,
}

Cell_Kind :: enum {
	Safe,
	Mine,
}

Cell_State :: enum {
	Concealed,
	Revealed,
	Flagged,
}

Cell :: struct {
	kind:           Cell_Kind,
	state:          Cell_State,
	adjacent_mines: u8,
}

cell_draw :: proc(cell: Cell, idx: int, field: ^Field) {
	coords := cell_from_index(idx, field.cols)
	rect := cell_rect(field, coords)

	// size of markers, e.g. flags, mines etc.
	marker_size :: 48

	// draw backround
	rl.DrawRectangleRec(rect, cell.state == .Revealed ? CELL_BG_REVEALED : CELL_BG_HIDDEN)
	rl.DrawRectangleLinesEx(rect, CELL_BORDER_WIDTH, CELL_BORDER_COLOR)

	// draw flag marker
	if cell.state == .Flagged {
		text := strings.clone_to_cstring("?", context.temp_allocator)
		w := f32(rl.MeasureText(text, marker_size))
		rl.DrawText(
			text,
			i32(rect.x + rect.width / 2 - w / 2),
			i32(rect.y + rect.height / 2 - marker_size / 2),
			marker_size,
			rl.ORANGE,
		)
	}

	when ODIN_DEBUG {
		debug_text := fmt.ctprintf(
			"idx=%d\n(%d,%d)\n%v (%d)",
			idx,
			coords.col,
			coords.row,
			cell.kind == .Mine ? "Mine" : "Safe",
			cell.kind == .Mine ? 0 : cell.adjacent_mines,
		)
		rl.DrawText(debug_text, i32(rect.x) + 1, i32(rect.y) + 1, 8, rl.PURPLE)
	}
}

////////////////////////////////////////////////////////////////////////////////
// Cell coordinate helpers
////////////////////////////////////////////////////////////////////////////////

// Return the size (edge length) of a single cell.
// NOTE: cells are always square, so one value suffices
cell_size :: proc(field: ^Field) -> f32 {
	return field.bounds.width / f32(field.cols)
}

// Returns the flat array index for specific cell coordinates.
cell_to_index :: proc(coords: Coord, cols: u8) -> int {
	return int(coords.row) * int(cols) + int(coords.col)
}

// Returns the coordinates of a cell given the index of a flat array.
cell_from_index :: proc(idx: int, cols: u8) -> Coord {
	return {col = u8(idx % int(cols)), row = u8(idx / int(cols))}
}

// Returns whether the given pos falls within the field, and if so, the index of
// that vector in the fields flat array.
// This proc is the same as subsequent calls to `cell_at` and `cell_to_index`.
cell_at_index :: proc(pos: rl.Vector2, field: ^Field) -> (idx: int, ok: bool) {
	coord := cell_at(pos, field) or_return
	return cell_to_index(coord, field.cols), true

}

// Return the coordinate (col, row) of a vector within the field, and whether
// that vector falls within the field to begin with.
cell_at :: proc(pos: rl.Vector2, field: ^Field) -> (cell_coord: Coord, ok: bool) {
	// check field boundries; split in x and y for better readibility
	if pos.x < field.bounds.x || pos.x > field.bounds.x + field.bounds.width {
		return {}, false
	}
	if pos.y < field.bounds.y || pos.y > field.bounds.y + field.bounds.height {
		return {}, false
	}

	cs := cell_size(field)
	col := u8((pos.x - field.bounds.x) / cs)
	row := u8((pos.y - field.bounds.y) / cs)

	// do some clamping for safety
	if col >= field.cols do col = clamp(col, 0, field.cols - 1)
	if row >= field.rows do row = clamp(row, 0, field.rows - 1)

	return {col, row}, true
}

// Returns the rectangle for a cell at specific coordinates.
cell_rect :: proc(field: ^Field, coords: Coord) -> rl.Rectangle {
	cs := cell_size(field)
	return {
		x = field.bounds.x + f32(coords.col) * cs,
		y = field.bounds.y + f32(coords.row) * cs,
		width = cs,
		height = cs,
	}
}


package main

import rl "vendor:raylib"

// WINDOW
//
WINDOW_WIDTH :: 768
WINDOW_HEIGHT :: 768
WINDOW_BG :: rl.WHITE
WINDOW_PADDING :: 8.0

// UI
//
UI_FONT_SIZE :: 24.0

// FIELD
//
// stored as Vec3 with {cols, rows, mines}
FIELD_BORDER_WIDTH :: 2.0
FIELD_BORDER_COLOR :: rl.BLACK
FIELD_BG :: rl.LIGHTGRAY

// FIELD SETTINGS
//
FIELD_SETTINGS_EASY :: FieldSettings {
	cols  = 9,
	rows  = 9,
	mines = 10,
}
FIELD_SETTINGS_MEDIUM :: FieldSettings {
	cols  = 16,
	rows  = 16,
	mines = 40,
}
FIELD_SETTINGS_HARD :: FieldSettings {
	cols  = 24,
	rows  = 24,
	mines = 99,
}


// CELLS
//
CELL_BORDER_WIDTH :: 1.0
CELL_BORDER_COLOR :: rl.BLACK
CELL_BG_HIDDEN :: rl.DARKGRAY
CELL_BG_REVEALED :: rl.LIGHTGRAY
CELL_FG_NUMBER :: rl.YELLOW
CELL_FG_FLAG :: rl.ORANGE
CELL_FG_MINE :: rl.RED

// GAME
//
@(rodata)
GAME_DIFFICULTY_FIELD_SETTINGS := [Difficulty]FieldSettings {
	.Easy   = FIELD_SETTINGS_EASY,
	.Medium = FIELD_SETTINGS_MEDIUM,
	.Hard   = FIELD_SETTINGS_HARD,
}


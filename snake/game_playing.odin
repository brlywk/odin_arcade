package main

import "core:log"
import rl "vendor:raylib"

game_update_playing :: proc(game: ^Game) {
	// player inputs always need to be queued
	player_queue_input(&game.player)

	// skip all other updates if it's not the next "step"
	if !_next_step(game) do return

	// player movement
	next_move := player_next_move(&game.player)
	log.debug("next move", next_move)

	can_move := valid_move(next_move) && !player_occupies_field(&game.player, next_move)
	log.debug("next move valid", can_move)

	// collision with food
	if can_move && _collide_with_food(game) {
		log.debug("sneck ated foodz")
		game.score += u64(game.current_food.points)
		_spawn_food(game)
		player_noms(&game.player, next_move)
	}

	player_move(&game.player, can_move)

	// player win condition = becoming Jörmungandr (devouring the world)
	if len(game.player.segments) == (GAME_GRID_NUM * GAME_GRID_NUM) - 1 {
		game.won = true
		game.state = .Game_Over
	}

	// re-check valid next move; if we can't move there after the player already moved,
	// we hit something and are super dead
	if !can_move {
		game.won = false
		game.state = .Game_Over
	}
}

game_draw_playing :: proc(game: ^Game) {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	// background
	rl.ClearBackground(BG_COLOR)

	// game field
	field_draw_bg()

	// food
	food_draw(game.current_food)

	// player
	player_draw(game.player)

	// field border
	field_draw_border()

	// UI
	ui_draw_score(game^)
}

//
// "internal" procs (this is a learning game, don't bother me with stuff like "proper package structure" :P)
//

// Should the game move forward already?
_next_step :: proc(game: ^Game) -> bool {
	current_time := rl.GetTime()
	next_step_time := game.last_move_time + game.time_step

	if current_time >= next_step_time {
		log.debug("current:", current_time, "next: ", next_step_time)
		game.last_move_time = current_time
		return true
	}

	return false
}

_field_occupied :: proc(game: ^Game, pos: Vec2) -> bool {
	has_food := game.current_food.pos == pos
	has_sneck := player_occupies_field(&game.player, pos)

	return has_food || has_sneck
}

_spawn_food :: proc(game: ^Game) {
	spawn_at := field_random_pos()

	for _field_occupied(game, spawn_at) {
		spawn_at = field_random_pos()
	}

	log.debug("food spawned at:", spawn_at)
	game.current_food = food_new(10, spawn_at)
}

_collide_with_food :: proc(game: ^Game) -> bool {
	return game.current_food.pos == player_next_move(&game.player)
}


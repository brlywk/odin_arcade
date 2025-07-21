package main

Game_State :: enum {
	Playing,
	Game_Over,
	Menu, // the version of me that added this was way more motivated than current me :P
}

Game :: struct {
	player:         Player,
	score:          u64,
	state:          Game_State,
	time_step:      f64, // one game step every x seconds
	last_move_time: f64,
	current_food:   Food,
	won:            bool, // game over and win state are pretty much the same, so a flag should suffice
}

game_new :: proc(player: Player, time_step: f64) -> Game {
	return Game{player = player, time_step = time_step}
}

game_init :: proc(game: ^Game) {
	_spawn_food(game)
}

game_reset :: proc(game: ^Game) {
	// free player allocations
	player_delete(&game.player)

	game.player = player_new(field_center())
	game.score = 0
	game.state = .Playing
	game.last_move_time = 0.0

	_spawn_food(game)
}

game_update :: proc(game: ^Game) {
	#partial switch game.state {
	case .Playing:
		game_update_playing(game)
	case .Game_Over:
		game_over_update(game)
	// Things I can't be bothered with in a "learning project": Menus! ;)
	}
}

game_draw :: proc(game: ^Game) {
	#partial switch game.state {
	case .Playing:
		game_draw_playing(game)
	case .Game_Over:
		game_over_draw(game)
	}
}

game_destroy :: proc(game: ^Game) {
	player_delete(&game.player)
}


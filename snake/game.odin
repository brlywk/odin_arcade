package main

Game_State :: enum {
	Playing,
	Game_Over,
	Menu,
}

Game :: struct {
	player:         Player,
	score:          u64,
	state:          Game_State,
	time_step:      f64, // one game step every x seconds
	last_move_time: f64,
	current_food:   Food,
}

game_new :: proc(player: Player, time_step: f64) -> Game {
	return Game{player = player, time_step = time_step}
}

game_init :: proc(game: ^Game) {
	_spawn_food(game)
}

game_update :: proc(game: ^Game) {
	#partial switch game.state {
	case .Playing:
		game_update_playing(game)
	}
}

game_draw :: proc(game: ^Game) {
	#partial switch game.state {
	case .Playing:
		game_draw_playing(game)
	}
}

game_destroy :: proc(game: ^Game) {
	player_delete(&game.player)
}


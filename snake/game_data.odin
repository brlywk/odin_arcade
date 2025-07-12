package main

Game_State :: enum {
	Playing,
	Game_Over,
	Menu,
}

Game_Data :: struct {
	score: u64,
	state: Game_State,
}


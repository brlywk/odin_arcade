package main

import rl "vendor:raylib"

//
// Constants
//

FOOD_SIZE :: 8
FOOD_COLOR :: rl.ORANGE

Food :: struct {
	points: i32,
	pos:    Vec2,
	eaten:  bool,
}

food_new :: proc(points: i32, pos: Vec2) -> Food {
	return Food{points = points, pos = pos}
}

food_draw :: proc(food: Food) {
	center := food.pos + PLAYER_SEGMENT_SIZE / 2
	rl.DrawCircle(i32(center.x), i32(center.y), FOOD_SIZE, FOOD_COLOR)
}


package main

import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math"
import "core:math/rand"
import "core:mem"
import rl "vendor:raylib"

// some convenience
Vec2 :: rl.Vector2
Rect :: rl.Rectangle


// constants
WINDOW_WIDTH :: 1024
WINDOW_HEIGHT :: 768

PADDING_HORIZONTAL :: 124 // 1024 - 124 = 900 -> 900 px of space to draw bricks 

BRICK_ROWS :: 5
BRICK_COLS :: 10
BRICK_HEIGHT :: 42
BRICK_WIDTH :: (WINDOW_WIDTH - PADDING_HORIZONTAL) / BRICK_COLS
BRICK_BASE_POINTS :: 5

PLAYER_WIDTH :: 100
PLAYER_HEIGHT :: 21
PLAYER_SPEED :: 350

BALL_RADIUS :: 10
BALL_MIN_X :: 50
BALL_MAX_X :: 100
BALL_Y :: 250

BG_COLOR :: rl.LIGHTGRAY


// lazyiness
BrickArray :: [BRICK_ROWS][BRICK_COLS]Brick


/*
   Main
*/

main :: proc() {
	when ODIN_DEBUG {
		// tracking allocator for learning purposes
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		// defer mem.tracking_allocator_destroy(&track) - see comment below
		context.allocator = mem.tracking_allocator(&track)
		defer check_tracking_allocator(&track, true) // use helper to destroy allocator
	}
	// set up logger
	context.logger = log.create_console_logger()
	defer log.destroy_console_logger(context.logger)

	// set up rng
	random_state := rand.create(42)
	context.random_generator = runtime.default_random_generator(&random_state)

	// setup game
	state := GameState{}
	bricks: BrickArray

	// create bricks
	bricks_reset(&bricks)

	// create player
	player := player_reset()

	// the infamous ball
	ball := ball_init()

	// init raylib window
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Breakout")
	defer rl.CloseWindow()

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()

		// UPDATE
		if !state.game_over {
			player_move(&player, dt)
			ball_move(&ball, player, &bricks, &state, dt)
		}

		// DRAW
		rl.BeginDrawing()
		defer rl.EndDrawing()

		// yes this could be way nicer, no I can't be bothered...
		if !state.game_over {
			rl.ClearBackground(BG_COLOR)

			// draw bricks
			bricks_draw_all(bricks)

			// draw player
			player_draw(player)

			// draw ball
			ball_draw(ball)

			// draw score
			score_text := fmt.ctprintf("Score: %d", state.score)
			rl.DrawText(score_text, 3, 3, 24, rl.BLACK)
		} else {
			rl.ClearBackground(rl.BLACK)

			// draw game over text
			game_over_text := fmt.ctprintf("Game Over! Final score: %d", state.score)
			font_size_game_over: i32 = 42
			game_over_text_width := rl.MeasureText(game_over_text, font_size_game_over)

			rl.DrawText(
				game_over_text,
				WINDOW_WIDTH / 2 - game_over_text_width / 2,
				WINDOW_HEIGHT / 2 - font_size_game_over / 2,
				font_size_game_over,
				rl.WHITE,
			)

			// draw restart text
			restart_text := fmt.ctprint("Press 'R' to restart.")
			font_size_restart: i32 = 26
			restart_text_width := rl.MeasureText(restart_text, font_size_restart)

			rl.DrawText(
				restart_text,
				WINDOW_WIDTH / 2 - restart_text_width / 2,
				WINDOW_HEIGHT / 2 + font_size_game_over - font_size_restart / 2,
				font_size_restart,
				rl.WHITE,
			)

			// reset game
			if rl.IsKeyPressed(rl.KeyboardKey.R) {
				game_reset(&state, &bricks, &player, &ball)
			}
		}
	}
}

game_reset :: proc(state: ^GameState, bricks: ^BrickArray, player: ^Player, ball: ^Ball) {
	state.game_over = false
	state.score = 0

	player^ = player_reset()
	bricks_reset(bricks)
	ball^ = ball_init()
}


/*
   Game Data
*/


GameState :: struct {
	score:     int,
	game_over: bool,
}

/*
   Player Stuff
*/

Player :: struct {
	rect:  Rect,
	speed: f32,
}

player_move :: proc(player: ^Player, dt: f32) {
	left := rl.IsKeyDown(rl.KeyboardKey.H) || rl.IsKeyDown(rl.KeyboardKey.LEFT)
	right := rl.IsKeyDown(rl.KeyboardKey.L) || rl.IsKeyDown(rl.KeyboardKey.RIGHT)

	dir := f32(int(right) - int(left)) * player.speed * dt
	player.rect.x += dir
	player.rect.x = clamp(player.rect.x, 0, WINDOW_WIDTH - player.rect.width)
}

player_draw :: proc(player: Player) {
	rl.DrawRectangleRec(player.rect, rl.DARKGRAY)
	rl.DrawRectangleLinesEx(player.rect, 1.0, rl.BLACK)
}

player_reset :: proc() -> Player {
	return Player {
		rect = {
			x = WINDOW_WIDTH / 2 - PLAYER_WIDTH / 2,
			y = WINDOW_HEIGHT - PADDING_HORIZONTAL / 2,
			width = PLAYER_WIDTH,
			height = PLAYER_HEIGHT,
		},
		speed = PLAYER_SPEED,
	}
}

/*
   Ball Stuff
*/

Ball :: struct {
	pos:      Vec2,
	radius:   f32,
	velocity: Vec2,
}


ball_move :: proc(ball: ^Ball, player: Player, bricks: ^BrickArray, state: ^GameState, dt: f32) {
	ball.pos += ball.velocity * dt

	// wall bouncing
	if ball.pos.x - ball.radius <= 0 || ball.pos.x + ball.radius >= WINDOW_WIDTH {
		ball.velocity.x = -ball.velocity.x
	}
	if ball.pos.y - ball.radius <= 0 {
		ball.velocity.y = -ball.velocity.y
	}
	// ball hits lower window border -> game over
	if ball.pos.y + ball.radius >= WINDOW_HEIGHT {
		ball.velocity.y = -ball.velocity.y
		state.game_over = true
	}

	// collision with player paddle
	if rl.CheckCollisionCircleRec(ball.pos, ball.radius, player.rect) {
		ball.velocity.y = -abs(ball.velocity.y)
	}

	// colliding with bricks
	for &row in bricks {
		for &brick in row {
			if brick.points > 0 && rl.CheckCollisionCircleRec(ball.pos, ball.radius, brick.rect) {
				// 1. what direction is the ball approaching the brick?
				brick_center := Vec2 {
					brick.rect.x + brick.rect.width / 2,
					brick.rect.y + brick.rect.height / 2,
				}
				delta := ball.pos - brick_center

				// 2. which half (top/bottom or left/right) has the most overlap?
				combined_half_width := ball.radius + brick.rect.width / 2
				combined_half_height := ball.radius + brick.rect.height / 2
				overlap_x := combined_half_width - abs(delta.x)
				overlap_y := combined_half_height - abs(delta.y)

				// 3. flip direction
				if overlap_x >= overlap_y {
					// y overlap is smaller, so it's a top/bottom collision
					if delta.y > 0 {
						// from above
						ball.pos.y += overlap_y
					} else {
						// from below
						ball.pos.y -= overlap_y
					}
					ball.velocity.y = -ball.velocity.y
				} else {
					// x overlap is smaller
					if delta.x > 0 {
						// from left
						ball.pos.x += overlap_x
					} else {
						// from right
						ball.pos.x -= overlap_x
					}
					ball.velocity.x = -ball.velocity.x
				}

				state.score += brick.points
				// mark brick as "hit"
				brick.points = 0
				return
			}
		}
	}
}


ball_draw :: proc(ball: Ball) {
	rl.DrawCircleV(ball.pos, ball.radius, rl.BLACK)
	rl.DrawCircleLinesV(ball.pos, ball.radius, rl.WHITE)
}

ball_init :: proc() -> Ball {
	initial_x := rand.float32_range(BALL_MIN_X, BALL_MAX_X)
	initial_x *= rand.choice([]f32{-1.0, 1.0})

	ball := Ball {
		pos      = {WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2},
		radius   = BALL_RADIUS,
		velocity = {initial_x, BALL_Y},
	}
	return ball
}

/*
   Ball Stuff
*/

Brick :: struct {
	row:    int,
	col:    int,
	rect:   Rect,
	points: int,
}

brick_draw :: proc(brick: Brick) {
	if brick.points == 0 {
		return
	}

	// very dumb color variation option...
	color := rl.Color{42, 123, u8(clamp(42, 255 - 7 * brick.points, 255)), 255}
	// color_border := color - 42
	color_border := BG_COLOR

	rl.DrawRectangleRec(brick.rect, color)
	rl.DrawRectangleLinesEx(brick.rect, 1.5, color_border)
}

bricks_draw_all :: proc(bricks: BrickArray) {
	for row in bricks {
		for brick in row {
			brick_draw(brick)
		}
	}
}

bricks_reset :: proc(bricks: ^BrickArray) {
	// where to draw the first brick
	brick_start_xy := PADDING_HORIZONTAL / 2

	for row, row_idx in bricks {
		for col, col_idx in row {
			x := brick_start_xy + col_idx * int(BRICK_WIDTH)
			y := brick_start_xy + row_idx * int(BRICK_HEIGHT)

			bricks[row_idx][col_idx] = Brick {
				row = row_idx,
				col = col_idx,
				points = (BRICK_ROWS - row_idx) * BRICK_BASE_POINTS,
				rect = {x = f32(x), y = f32(y), width = BRICK_WIDTH, height = BRICK_HEIGHT},
			}
		}
	}
}


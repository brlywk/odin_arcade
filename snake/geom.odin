package main

// Returns width and height for the given rl.Rectange rect.
rect_get_size_wh :: proc(rect: Rect) -> (width, height: f32) {
	return rect.width, rect.height
}

// Returns x and y for the given rl.Rectangle rect.
rect_get_position_xy :: proc(rect: Rect) -> (x, y: f32) {
	return rect.x, rect.y
}

rect_get_position_vec2 :: proc(rect: Rect) -> Vec2 {
	return Vec2{rect.x, rect.y}
}


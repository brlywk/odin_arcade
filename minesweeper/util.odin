package main

import rl "vendor:raylib"

rect_center :: #force_inline proc(rect: rl.Rectangle) -> [2]f32 {
	return {rect.x + rect.width / 2, rect.y + rect.height / 2}
}

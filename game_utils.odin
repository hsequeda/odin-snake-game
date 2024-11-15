package main

import sdl "vendor:sdl2"

Vec2 :: [2]i32

// delta_time returns the time since last frame.
delta_time :: proc(g: ^Game) -> u32 {
	resp := sdl.GetTicks() - g.prev_frame_ticks
	g.prev_frame_ticks = sdl.GetTicks()
	return resp
}

package main


import sdl "vendor:sdl2"
import "vendor:sdl2/ttf"

Menu :: struct {
	start_btn:      Button,
	quit_btn:       Button,
	prev_snake_dir: Vec2,
}


init_menu :: proc(r: ^sdl.Renderer, f: ^ttf.Font) -> Menu {
	return Menu {
		start_btn = init_button(
			r,
			f,
			sdl.FRect{(((BOARD_WIDTH * TILE_SIZE)) / 2) - 75, 100, 150, 40},
			"Start",
			sdl.Color{200, 200, 0, 10},
		),
		quit_btn = init_button(
			r,
			f,
			sdl.FRect{(((BOARD_WIDTH * TILE_SIZE)) / 2) - 75, 150, 150, 40},
			"Quit",
			sdl.Color{200, 200, 0, 10},
		),
	}
}

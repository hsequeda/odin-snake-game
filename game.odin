package main

import "core:fmt"
import "core:strings"
import sdl "vendor:sdl2"
import "vendor:sdl2/ttf"

SDL_FLAGS :: sdl.INIT_EVERYTHING
WINDOW_FLAGS :: sdl.WINDOW_SHOWN
RENDERER_FLAGS :: sdl.RENDERER_ACCELERATED

WINDOW_TITLE :: "Snake Game"

// Number of tiles for width and height
BOARD_WIDTH :: 20
BOARD_HEIGHT :: 20
TILE_SIZE :: 16

FONT_SIZE :: 20

TICK_RATE :: 0.16
tick_timer: f32 = TICK_RATE


Scene :: enum {
	Menu,
	Game,
	GameOver, // TODO: Implements it!
}


Game :: struct {
	font:             ^ttf.Font,
	window:           ^sdl.Window,
	renderer:         ^sdl.Renderer,
	snake:            Snake,
	apple:            Apple,
	score_tex:        ^sdl.Texture,
	score:            u32,
	menu:             Menu,

	// scene saves what scene is currently running
	scene:            Scene,

	// prev_frame_ticks is the number of ms since the sdl.Initialization to previous frame.
	prev_frame_ticks: u32,
}


initialize :: proc(g: ^Game) -> bool {
	if sdl.Init(SDL_FLAGS) != 0 {return false}
	if ttf.Init() != 0 {return false}

	// Load font
	g.font = ttf.OpenFont("./fonts/freesansbold.ttf", FONT_SIZE)
	// ttf.CloseFont(g.font)

	if g.window = sdl.CreateWindow(
		WINDOW_TITLE,
		sdl.WINDOWPOS_CENTERED,
		sdl.WINDOWPOS_CENTERED,
		BOARD_WIDTH * TILE_SIZE,
		BOARD_HEIGHT * TILE_SIZE,
		WINDOW_FLAGS,
	); g.window == nil {
		return false
	}

	if g.renderer = sdl.CreateRenderer(g.window, -1, RENDERER_FLAGS); g.renderer == nil {
		return false
	}

	g.snake = init_snake(Vec2{(BOARD_WIDTH / 2), (BOARD_WIDTH / 2)}, sdl.Color{50, 0, 30, 255})
	g.apple = init_apple(get_snake_tiles(g.snake))

	g.menu = init_menu(g.renderer, g.font)

	g.scene = Scene.Menu
	return true
}


run :: proc(g: ^Game) {
	for {
		if handle_events(g) {return}

		tick_timer -= f32(delta_time(g)) / 1000
		if tick_timer <= 0 {
			snake_move(&g.snake)
			if g.snake.head == g.apple {
				snake_grow(&g.snake)
				g.apple = init_apple(get_snake_tiles(g.snake))
				g.score += 1
			}

			tick_timer += TICK_RATE
			draw(g)
		}
	}
}


@(private = "file")
draw :: proc(g: ^Game) {
	// Set the draw color to a light gray for the background
	// load the renderer with Grey color
	sdl.SetRenderDrawColor(g.renderer, 30, 150, 30, 255)
	// Clear renderer (doc => https://wiki.libsdl.org/SDL2/SDL_RenderClear)
	// This function clear the background with the drawing color
	sdl.RenderClear(g.renderer)

	fmt.println(g.scene)
	#partial switch g.scene {
	case .Menu:
		draw_menu(g)
	case .Game:
		draw_apple(g)
		snake_render(&g.snake, g.renderer)
		draw_hud(g)
	}

	sdl.RenderPresent(g.renderer)
}

@(private = "file")
draw_apple :: proc(g: ^Game) {
	sdl.SetRenderDrawColor(g.renderer, 255, 0, 0, 255)
	sdl.RenderFillRectF(
		g.renderer,
		&sdl.FRect{f32(g.apple.x) * TILE_SIZE, f32(g.apple.y) * TILE_SIZE, TILE_SIZE, TILE_SIZE},
	)
}

// draw_hud draws the HUD (Heads-Up Display) on the screen.
@(private = "file")
draw_hud :: proc(g: ^Game) {
	if g.score_tex != nil {sdl.DestroyTexture(g.score_tex)}

	surf := ttf.RenderText_Blended(
		g.font,
		strings.clone_to_cstring(fmt.tprintf("Score: %d", g.score)),
		sdl.Color{10, 10, 10, 200},
	)
	g.score_tex = sdl.CreateTextureFromSurface(g.renderer, surf)
	sdl.FreeSurface(surf)
	sdl.RenderCopy(
		g.renderer,
		g.score_tex,
		nil,
		&sdl.Rect{x = ((BOARD_WIDTH * TILE_SIZE) - surf.w) / 2, w = surf.w, h = surf.h},
	)
}

// game_clean ends all the initialized processes and deallocate used memory.
game_clean :: proc(g: ^Game) {
	snake_destroy(&g.snake)
	button_clean(&g.menu.start_btn)
	button_clean(&g.menu.quit_btn)

	if g.score_tex != nil {sdl.DestroyTexture(g.score_tex)}
	sdl.DestroyWindow(g.window)
	sdl.DestroyRenderer(g.renderer)

	ttf.CloseFont(g.font)
	ttf.Quit()
	sdl.Quit()
}

draw_menu :: proc(g: ^Game) {
	button_render(&g.menu.start_btn, g.renderer)
	button_render(&g.menu.quit_btn, g.renderer)
}

package main

import "core:fmt"
import sdl "vendor:sdl2"

SDL_FLAGS :: sdl.INIT_EVERYTHING
WINDOW_FLAGS :: sdl.WINDOW_SHOWN
RENDERER_FLAGS :: sdl.RENDERER_ACCELERATED

WINDOW_TITLE :: "Snake Game"

// Number of tiles for width and height
BOARD_WIDTH :: 20
BOARD_HEIGHT :: 20
TILE_SIZE :: 16

TICK_RATE :: 0.9
tick_timer: f32 = TICK_RATE


Game :: struct {
	window:           ^sdl.Window,
	renderer:         ^sdl.Renderer,
	snake:            Snake,
	apple:            Apple,

	// prev_frame_ticks is the number of ms since the sdl.Initialization to previous frame.
	prev_frame_ticks: u32,
}


initialize :: proc(g: ^Game) -> bool {
	if sdl.Init(SDL_FLAGS) != 0 {
		return false
	}

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
			}

			tick_timer += TICK_RATE
			draw(g)
		}
	}
}


// TODO: improve it, handle events should handle the events, it shouldn't return anything
// The closing event should be handled in a different way.
handle_events :: proc(g: ^Game) -> bool {
	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			return true
		case .KEYDOWN:
			#partial switch event.key.keysym.scancode {
			case .ESCAPE:
				return true
			case .UP:
				snake_set_dir(&g.snake, Vec2{0, -1})
			case .LEFT:
				snake_set_dir(&g.snake, Vec2{-1, 0})
			case .RIGHT:
				snake_set_dir(&g.snake, Vec2{1, 0})
			case .DOWN:
				snake_set_dir(&g.snake, Vec2{0, 1})
			}
		}
	}

	return false
}

draw :: proc(g: ^Game) {
	// Set the draw color to a light gray for the background
	// load the renderer with Grey color
	sdl.SetRenderDrawColor(g.renderer, 30, 150, 30, 255)
	// Clear renderer (doc => https://wiki.libsdl.org/SDL2/SDL_RenderClear)
	// This function clear the background with the drawing color
	sdl.RenderClear(g.renderer)

	draw_apple(g)
	draw_snake(g)

	sdl.RenderPresent(g.renderer)
}

draw_apple :: proc(g: ^Game) {
	sdl.SetRenderDrawColor(g.renderer, 255, 0, 0, 255)
	sdl.RenderFillRectF(
		g.renderer,
		&sdl.FRect{f32(g.apple.x) * TILE_SIZE, f32(g.apple.y) * TILE_SIZE, TILE_SIZE, TILE_SIZE},
	)
}

draw_snake :: proc(g: ^Game) {
	sdl.SetRenderDrawColor(
		g.renderer,
		g.snake.color.r,
		g.snake.color.g,
		g.snake.color.b,
		g.snake.color.a,
	)


	// Draw head
	sdl.RenderFillRectF(
		g.renderer,
		&sdl.FRect {
			f32(g.snake.head.x) * TILE_SIZE,
			f32(g.snake.head.y) * TILE_SIZE,
			TILE_SIZE,
			TILE_SIZE,
		},
	)


	// Draw body
	for t in g.snake.body {
		sdl.RenderFillRectF(
			g.renderer,
			&sdl.FRect{f32(t.x) * TILE_SIZE, f32(t.y) * TILE_SIZE, TILE_SIZE, TILE_SIZE},
		)
	}
}

// game_clean ends all the initialized processes and deallocate used memory.
game_clean :: proc(g: ^Game) {
	snake_destroy(&g.snake)
	sdl.DestroyWindow(g.window)
	sdl.DestroyRenderer(g.renderer)

	sdl.Quit()
}

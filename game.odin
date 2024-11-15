package main

import "core:fmt"
import "core:math/rand"
import sdl "vendor:sdl2"

SDL_FLAGS :: sdl.INIT_EVERYTHING
WINDOW_FLAGS :: sdl.WINDOW_SHOWN
RENDERER_FLAGS :: sdl.RENDERER_ACCELERATED

WINDOW_TITLE :: "Snake Game"

// Number of tiles for width and height
BOARD_WIDTH :: 20
BOARD_HEIGHT :: 20
TILE_SIZE :: 16

TICK_RATE :: 0.13
tick_timer: f32 = TICK_RATE


Game :: struct {
	window:           ^sdl.Window,
	renderer:         ^sdl.Renderer,
	snake:            Snake,
	apple:            Vec2,

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
    g.apple = init_apple(get_busy_tiles(g.snake)[:])

	return true
}

run :: proc(g: ^Game) {
	for {
		if handle_events(g) {return}

		// Set the draw color to a light gray for the background
		// load the renderer with Grey color
		sdl.SetRenderDrawColor(g.renderer, 30, 150, 30, 255)
		// Clear renderer (doc => https://wiki.libsdl.org/SDL2/SDL_RenderClear)
		// This function clear the background with the drawing color
		sdl.RenderClear(g.renderer)


		tick_timer -= f32(delta_time(g)) / 1000
		if tick_timer <= 0 {
            if g.snake.head == g.apple {
			    move_snake(&g.snake, true)
                g.apple = init_apple(get_busy_tiles(g.snake)[:])
            }else {
			    move_snake(&g.snake, false)
            }

			tick_timer += TICK_RATE
		}

        draw_apple(g)
		draw_snake(g)

		sdl.RenderPresent(g.renderer)
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
				change_snake_dir(&g.snake, Vec2{0, -1})
			case .LEFT:
				change_snake_dir(&g.snake, Vec2{-1, 0})
			case .RIGHT:
				change_snake_dir(&g.snake, Vec2{1, 0})
			case .DOWN:
				change_snake_dir(&g.snake, Vec2{0, 1})
			}
		}
	}

	return false
}

draw_apple :: proc (g: ^Game) {
	sdl.SetRenderDrawColor( g.renderer, 255, 0, 0, 255)
	sdl.RenderFillRectF(
		g.renderer,
		&sdl.FRect {
			f32(g.apple.x) * TILE_SIZE,
			f32(g.apple.y) * TILE_SIZE,
			TILE_SIZE,
			TILE_SIZE,
		},
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

init_apple :: proc(busy_tiles: []Vec2) -> Vec2 {

	is_apple_used := proc(a: Vec2, bt: []Vec2) -> bool {
		for bt in bt {
			if a == bt {return true}
		}
		return false
	}
	for {
		apple := Vec2{rand.int31_max(BOARD_WIDTH), rand.int31_max(BOARD_HEIGHT)}
		if !is_apple_used(apple, busy_tiles) {
			return apple
		}
	}
}

package main

import "core:fmt"
import sdl "vendor:sdl2"

handle_events :: proc(g: ^Game) -> bool {
	event: sdl.Event
	for sdl.PollEvent(&event) {
		// Global events
		if event.type == .QUIT {return true}

		// Scene events
		switch g.scene {
		case .Menu:
			return handle_menu_events(g, event)
		case .Game:
			return handle_game_events(g, event) // always returns false
		case .GameOver:
		}
	}

	return false
}

@(private = "file")
handle_menu_events :: proc(g: ^Game, event: sdl.Event) -> bool {
	#partial switch event.type {
	case .MOUSEBUTTONDOWN:
		if button_is_pressed(&g.menu.start_btn, event.button) {
			g.scene = .Game
			snake_set_dir(&g.snake, g.menu.prev_snake_dir)
		} else if button_is_pressed(&g.menu.quit_btn, event.button) {
			return true
		}
	}

	return false
}

@(private = "file")
handle_game_events :: proc(g: ^Game, event: sdl.Event) -> bool {
	#partial switch event.type {
	case .KEYDOWN:
		#partial switch event.key.keysym.scancode {
		case .ESCAPE:
			g.menu.prev_snake_dir = g.snake.dir
			snake_set_dir(&g.snake, Vec2{0, 0})
			g.scene = .Menu
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

	return false
}

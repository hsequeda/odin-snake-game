package main

import "core:fmt"
import "core:slice"
import sdl "vendor:sdl2"

Snake :: struct {
	dir, next_dir: Vec2,
	color:         sdl.Color,
	head:          Vec2,
	body:          [dynamic]Vec2,
}


init_snake :: proc(initial_pos: Vec2, color: sdl.Color) -> Snake {
	s := Snake {
		dir   = Vec2{1, 0}, // Right (->)
		color = color,
		head  = initial_pos,
	}

	append(&s.body, initial_pos - Vec2{1, 0}, initial_pos - Vec2{2, 0})
	return s
}

// get_busy_tiles returns the tiles occupied by the Snake.
get_snake_tiles :: proc(s: Snake) -> []Vec2 {
	tb := make([]Vec2, len(s.body) + 1)
	tb[0] = s.head
	for t, i in s.body {
		tb[i + 1] = t
	}

	return tb
}

move_snake :: proc(s: ^Snake, should_grow: bool) {
	s.dir = s.next_dir

	// stop the snake if it collide with the end of the board
	switch {
	case s.head.x + 1 > BOARD_WIDTH:
		s.dir = Vec2{0, 0}
		return
	case s.head.x < 0:
		s.dir = Vec2{0, 0}
		return
	case s.head.y + 1 > BOARD_HEIGHT:
		s.dir = Vec2{0, 0}
		return
	case s.head.y < 0:
		s.dir = Vec2{0, 0}
		return
	case slice.any_of(s.body[:], s.head + s.dir):
		s.dir = Vec2{0, 0}
		return
	}


	n_pos := s.body[len(s.body) - 1]
	#reverse for &t, i in s.body {
		if i > 0 {
			t = s.body[i - 1]
		} else {
			t = s.head
		}
	}

	s.head += s.dir
	if should_grow {append(&s.body, n_pos)}
}

set_snake_dir :: proc(s: ^Snake, ndir: Vec2) {
	if s.dir != ndir * -1 {
		s.next_dir = ndir
	}
}

destroy_snake :: proc(s: ^Snake) {
	delete(s.body)
}

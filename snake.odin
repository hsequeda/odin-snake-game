package main

import "core:fmt"
import sdl "vendor:sdl2"


Snake :: struct {
	dir:   Vec2,
	color: sdl.Color,
	head:  Vec2,
	body:  [dynamic]Vec2,
}


init_snake :: proc(initial_pos: Vec2, color: sdl.Color) -> Snake {
	s := Snake {
		dir   = Vec2{1, 0},
		color = color,
		head  = initial_pos,
	}

	append(&s.body, initial_pos - Vec2{1, 0}, initial_pos - Vec2{2, 0})
	return s
}

move_snake :: proc(s: ^Snake, does_eat: bool) {
	// stop the snake if it collide with the end of the board
	switch {
	case s.head.x + 1 >= BOARD_WIDTH:
		s.dir = Vec2{0, 0}
	case s.head.x <= 0:
		s.dir = Vec2{0, 0}
	case s.head.y + 1 >= BOARD_WIDTH:
		s.dir = Vec2{0, 0}
	case s.head.y <= 0:
		s.dir = Vec2{0, 0}
	}

	old_pos := s.head
	n_pos := old_pos
	s.head += s.dir
	for &t in s.body {
		n_pos = t
		t = old_pos
		old_pos = n_pos
	}

	if does_eat {
		append(&s.body, n_pos)
	}
}

change_snake_dir :: proc(s: ^Snake, dir: Vec2) {
	if s.dir != dir * -1 {
		s.dir = dir
	}
}


get_busy_tiles :: proc(s: Snake) -> [dynamic]Vec2 {
	bt: [dynamic]Vec2
	append(&bt, s.head)
	for t in s.body {
		append(&bt, t)
	}

	return bt
}

package main

import "core:fmt"
import sdl "vendor:sdl2"

main :: proc() {
	game: Game
	if !initialize(&game) {
		fmt.eprintln("error initializing")
	}

	run(&game)
}

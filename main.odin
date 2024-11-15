package main

import "core:fmt"
import sdl "vendor:sdl2"

main :: proc() {
	x := [?]i32{1, 2, 3, 4, 5, 6, 7, 8}
	#reverse for t, i in x {
		fmt.println(i)
	}

	game: Game
	if !initialize(&game) {
		fmt.eprintln("error initializing")
	}

	defer clean_game(&game)
	run(&game)

}

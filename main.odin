package main

import "core:fmt"

main :: proc() {
	game: Game
	if !initialize(&game) {
		fmt.eprintln("error initializing")
	}

	defer clean_game(&game)
	run(&game)
}

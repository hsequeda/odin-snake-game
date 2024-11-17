package main

import "core:fmt"

main :: proc() {
	game: Game
	if !initialize(&game) {
		fmt.eprintln("error initializing")
	}

	defer game_clean(&game)
	run(&game)
}

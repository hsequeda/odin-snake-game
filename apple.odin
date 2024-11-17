package main

import "core:math/rand"
import "core:slice"

Apple :: Vec2

init_apple :: proc(busy_tiles: []Vec2) -> Apple {
	for {
		apple := Apple{rand.int31_max(BOARD_WIDTH), rand.int31_max(BOARD_HEIGHT)}
		if !slice.any_of(busy_tiles, apple) {
			return apple
		}
	}
}

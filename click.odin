package yeeball


isValidClick :: proc(game: ^Game, world: ^World, x, y: i32) -> bool {
	if x <= world.border || x >= game.width - world.border {
		return false
	}
	if y <= world.border || y >= game.height - world.border {
		return false
	}

	return true
}

click :: proc(game: ^Game, world: ^World, x, y: i32) {
	if world.blueExtender.active == false {
		world.blueExtender.x = x
		world.blueExtender.y = y
		world.blueExtender.active = true
		world.blueExtender.length = 16
		world.blueExtender.horizontal = game.horizontal
	}

	if world.redExtender.active == false {
		world.redExtender.x = x
		world.redExtender.y = y
		world.redExtender.active = true
		world.redExtender.length = 16
		world.redExtender.horizontal = game.horizontal
	}
}

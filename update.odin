
package yeeball

updateWorld :: proc(game: Game, world: ^World, delta: f32) {
	for i := 0; i < len(world.balls); i += 1 {
		world.balls[i].position.x += world.balls[i].velocity.x * delta * game.ballSpeed
		world.balls[i].position.y += world.balls[i].velocity.y * delta * game.ballSpeed
		ballWallCollision(game, world, &world.balls[i])
	}

	updateExtenders(game, world, delta)
	extenderWallCollision(game, world)
}

updateExtenders :: proc(game: Game, world: ^World, delta: f32) {
	if world.blueExtender.active {
		world.blueExtender.length += delta * game.extenderSpeed
	}
	if world.redExtender.active {
		world.redExtender.length += delta * game.extenderSpeed
	}
}

convertToWall :: proc(game: Game, world: ^World, xStart, yStart, width, height: i32) {
	for x: i32 = 0; x < width; x += 1 {
		for y: i32 = 0; y < height; y += 1 {
			index := worldIndex(world, xStart + x, yStart + y)
			world.filled[index] = WorldState.WALL
		}
	}
}

nextLevel ::proc(game: ^Game, world: ^World) {
	game.lives += 1
	game.level += 1
}

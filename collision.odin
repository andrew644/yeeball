
package yeeball

ballWallCollision :: proc(game: Game, world: ^World, ball: ^Ball) {
	x := i32(ball.position.x)
	y := i32(ball.position.y)
	if world.filled[worldIndex(world, x + game.ballRadius + 1, y)] == WorldState.WALL {
		ball.velocity.x = -ball.velocity.x
	} 
	if world.filled[worldIndex(world, x, y + game.ballRadius + 1)] == WorldState.WALL {
		ball.velocity.y = -ball.velocity.y
	} 
	if world.filled[worldIndex(world, x - game.ballRadius - 1, y)] == WorldState.WALL {
		ball.velocity.x = -ball.velocity.x
	} 
	if world.filled[worldIndex(world, x, y - game.ballRadius - 1)] == WorldState.WALL {
		ball.velocity.y = -ball.velocity.y
	} 
}

extenderWallCollision :: proc(game: Game, world: ^World) {
	if world.blueExtender.active {
		x := world.blueExtender.x
		y := world.blueExtender.y
		length := i32(world.blueExtender.length)
		height := game.extenderSize
		if world.blueExtender.horizontal {
			indexTop := worldIndex(world, x + length, y)
			indexBottom := worldIndex(world, x + length, y + height)
			if world.filled[indexTop] == WorldState.WALL || world.filled[indexBottom] == WorldState.WALL {
				world.blueExtender.active = false				
				convertToWall(game, world, x, y, length, height)
			}
		} else {
			indexLeft := worldIndex(world, x, y + length)
			indexRight := worldIndex(world, x + height, y + length)
			if world.filled[indexLeft] == WorldState.WALL || world.filled[indexRight] == WorldState.WALL {
				world.blueExtender.active = false				
				convertToWall(game, world, x, y, height, length)
			}
		}
	}

	if world.redExtender.active {
		x := world.redExtender.x
		y := world.redExtender.y
		length := i32(world.redExtender.length)
		height := game.extenderSize
		if world.redExtender.horizontal {
			indexTop := worldIndex(world, x - length, y)
			indexBottom := worldIndex(world, x - length, y + height)
			if world.filled[indexTop] == WorldState.WALL || world.filled[indexBottom] == WorldState.WALL {
				world.redExtender.active = false				
				convertToWall(game, world, x - length, y, length, height)
			}
		} else {
			indexLeft := worldIndex(world, x, y - length)
			indexRight := worldIndex(world, x + height, y - length)
			if world.filled[indexLeft] == WorldState.WALL || world.filled[indexRight] == WorldState.WALL {
				world.redExtender.active = false				
				convertToWall(game, world, x, y - length, height, length)
			}
		}
	}
}
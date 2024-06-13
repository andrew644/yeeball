
package yeeball

import rl "vendor:raylib"
import "core:math"

ballWallCollision :: proc(game: ^Game, world: ^World, ball: ^Ball) {
	x := i32(ball.position.x)
	y := i32(ball.position.y)
	if world.filled[worldIndex(world, x + game.ballRadius + 1, y)] == WALL {
		ball.velocity.x = -ball.velocity.x
	} 
	if world.filled[worldIndex(world, x, y + game.ballRadius + 1)] == WALL {
		ball.velocity.y = -ball.velocity.y
	} 
	if world.filled[worldIndex(world, x - game.ballRadius - 1, y)] == WALL {
		ball.velocity.x = -ball.velocity.x
	} 
	if world.filled[worldIndex(world, x, y - game.ballRadius - 1)] == WALL {
		ball.velocity.y = -ball.velocity.y
	} 
}

ballExtenderCollision :: proc(game: ^Game, world: ^World, ball: ^Ball) {
	collision := false
	if world.blueExtender.active {
		x := world.blueExtender.x
		y := world.blueExtender.y
		if world.blueExtender.horizontal {
			width := i32(world.blueExtender.length)
			height := game.extenderSize
			collision = circleRectCollision(ball.position, game.ballRadius, x, y, width, height)
		} else {
			width := game.extenderSize
			height := i32(world.blueExtender.length)
			collision = circleRectCollision(ball.position, game.ballRadius, x, y, width, height)
		}

		if collision {
			ballExtenderCollisionTrue(game, world, &world.blueExtender)
		}
	}

	collision = false
	if world.redExtender.active {
		if world.redExtender.horizontal {
			width := i32(world.redExtender.length)
			x := world.redExtender.x - width
			y := world.redExtender.y
			height := game.extenderSize
			collision = circleRectCollision(ball.position, game.ballRadius, x, y, width, height)
		} else {
			width := game.extenderSize
			height := i32(world.redExtender.length)
			x := world.redExtender.x
			y := world.redExtender.y - height
			collision = circleRectCollision(ball.position, game.ballRadius, x, y, width, height)
		}

		if collision {
			ballExtenderCollisionTrue(game, world, &world.redExtender)
		}
	}
}

ballExtenderCollisionTrue :: proc(game: ^Game, world: ^World, extender: ^Extender) {
	extender.active = false
	game.lives -= 1
}

circleRectCollision :: proc(circle: rl.Vector2, radius: i32, rectX, rectY, width, height: i32) -> bool {
	circleX := i32(circle.x)
	circleY := i32(circle.y)

	testX := circleX
	testY := circleY

	if circleX < rectX {
		testX = rectX
	} else if circleX > rectX + width {
		testX = rectX + width
	}

	if circleY < rectY {
		testY = rectY
	} else if circleY > rectY + height {
		testY = rectY + height
	}

	distX : f32 = f32(circleX - testX)
	distY : f32 = f32(circleY - testY)
	distance := math.sqrt_f32((distX * distX) + (distY * distY))

	return distance <= f32(radius)
}

extenderWallCollision :: proc(game: ^Game, world: ^World) {
	if world.blueExtender.active {
		x := world.blueExtender.x
		y := world.blueExtender.y
		length := i32(world.blueExtender.length)
		height := game.extenderSize
		if world.blueExtender.horizontal {
			indexTop := worldIndex(world, x + length, y)
			indexBottom := worldIndex(world, x + length, y + height)
			if world.filled[indexTop] == WALL || world.filled[indexBottom] == WALL {
				world.blueExtender.active = false				
				convertToWall(game, world, x, y, length, height)
			}
		} else {
			indexLeft := worldIndex(world, x, y + length)
			indexRight := worldIndex(world, x + height, y + length)
			if world.filled[indexLeft] == WALL || world.filled[indexRight] == WALL {
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
			if world.filled[indexTop] == WALL || world.filled[indexBottom] == WALL {
				world.redExtender.active = false				
				convertToWall(game, world, x - length, y, length, height)
			}
		} else {
			indexLeft := worldIndex(world, x, y - length)
			indexRight := worldIndex(world, x + height, y - length)
			if world.filled[indexLeft] == WALL || world.filled[indexRight] == WALL {
				world.redExtender.active = false				
				convertToWall(game, world, x, y - length, height, length)
			}
		}
	}
}
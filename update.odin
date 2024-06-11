
package yeeball

import "core:fmt"

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
			world.filled[index] = WALL
		}
	}
	fillInGaps(game, world)
	world.fillPercent = i32(percentFilled(game, world) * 100)
}

nextLevel ::proc(game: ^Game, world: ^World) {
	game.lives += 1
	game.level += 1
}

percentFilled :: proc(game: Game, world: ^World) -> f32 {
	floor: f32 = 0
	wall: f32 = 0
	for x := world.border; x < game.width - world.border; x += 1 {
		for y := world.border; y < game.height - world.border; y += 1 {
			atIndex := world.filled[worldIndex(world, x, y)]
			if atIndex == WALL {
				wall += 1
			} else {
				floor += 1
			}
		}
	}
	return wall / (wall + floor)
}

fillInGaps :: proc(game: Game, world: ^World) {
	BALL_ROOM : byte : 2

	buffer := make([]byte, game.width * game.height)
	defer delete(buffer)
	for i := 0; i < len(buffer); i += 1 {
		buffer[i] = world.filled[i]
	}

	queue := make([dynamic]Point, 0, game.width * game.height)
	defer delete(queue)

	for ball in world.balls {
		x := i32(ball.position.x)
		y := i32(ball.position.y)
		append(&queue, Point{x, y})
	}

	for len(queue) > 0 {
		point := pop(&queue)
		index := worldIndex(world, point.x, point.y)
		atIndex := buffer[index]
		if atIndex == BALL_ROOM || atIndex == WALL {
			continue
		} else if atIndex == EMPTY {
			buffer[index] = BALL_ROOM
			append(&queue, Point{point.x - 1, point.y})
			append(&queue, Point{point.x + 1, point.y})
			append(&queue, Point{point.x, point.y - 1})
			append(&queue, Point{point.x, point.y + 1})
		}
	}

	for i := 0; i < len(buffer); i += 1 {
		if buffer[i] == EMPTY {
			world.filled[i] = WALL
		}
	}
}
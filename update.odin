
package yeeball

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

setMouse :: proc(game: ^Game) {
	if game.horizontal {
		rl.SetMouseCursor(rl.MouseCursor.RESIZE_EW)
	} else {
		rl.SetMouseCursor(rl.MouseCursor.RESIZE_NS)
	}
}

randomRange :: proc(lower, upper: u32) -> u32 {
	r := rand.uint32()
	return (r % (upper - lower + 1)) + lower
}

randomDirection :: proc() -> rl.Vector2 {
	r1 := rand.int31()
	r2 := rand.int31()

	return rl.Vector2{f32((r1 % 2) * 2 - 1), f32((r2 % 2) * 2 - 1)}
}

worldIndex :: proc(world: ^World, x, y: i32) -> i32 {
	return y * world.width + x
}

initWorld :: proc(game: ^Game, world: ^World) {
	//Clear world
	for i := 0; i < len(world.filled); i += 1 {
		world.filled[i] = EMPTY
	}
	
	world.redExtender.active = false
	world.blueExtender.active = false

	clear_dynamic_array(&world.balls)

	//Add balls
	rand.set_global_seed(2)
	for len(world.balls) < int(game.level + 1) {
		x := randomRange(u32(world.border + 16), u32(game.width - world.border - 16))
		y := randomRange(u32(world.border + 16), u32(game.height - world.border - 16))
		direction := randomDirection()

		append(&world.balls, Ball{position = rl.Vector2{f32(x), f32(y)}, velocity = direction})
	}

	//Add border
	for y: i32 = 0; y < world.border; y += 1 {
		for x: i32 = 0; x < world.width; x += 1 {
			index := worldIndex(world, x, y)
			world.filled[index] = WALL
		}
	}
	for y: i32 = world.height - world.border; y < world.height; y += 1 {
		for x: i32 = 0; x < world.width; x += 1 {
			index := worldIndex(world, x, y)
			world.filled[index] = WALL
		}
	}

	for y: i32 = 0; y < world.height; y += 1 {
		for x: i32 = 0; x < world.border; x += 1 {
			index := worldIndex(world, x, y)
			world.filled[index] = WALL
		}
		for x: i32 = world.width - world.border; x < world.width; x += 1 {
			index := worldIndex(world, x, y)
			world.filled[index] = WALL
		}
	}

	updateFilledPercent(game, world)
}

updateWorld :: proc(game: ^Game, world: ^World, delta: f32) {
	for i := 0; i < len(world.balls); i += 1 {
		world.balls[i].position.x += world.balls[i].velocity.x * delta * game.ballSpeed
		world.balls[i].position.y += world.balls[i].velocity.y * delta * game.ballSpeed
		ballWallCollision(game, world, &world.balls[i])
		ballExtenderCollision(game, world, &world.balls[i])
	}

	updateExtenders(game, world, delta)
	extenderWallCollision(game, world)
}

updateExtenders :: proc(game: ^Game, world: ^World, delta: f32) {
	if world.blueExtender.active {
		world.blueExtender.length += delta * game.extenderSpeed
	}
	if world.redExtender.active {
		world.redExtender.length += delta * game.extenderSpeed
	}
}

advanceLevel :: proc(game: ^Game, world: ^World) {
	game.level += 1
	game.lives += 1
	initWorld(game, world)
}

convertToWall :: proc(game: ^Game, world: ^World, xStart, yStart, width, height: i32) {
	for x: i32 = 0; x < width; x += 1 {
		for y: i32 = 0; y < height; y += 1 {
			index := worldIndex(world, xStart + x, yStart + y)
			world.filled[index] = WALL
		}
	}
	fillInGaps(game, world)
	updateFilledPercent(game, world)
	if world.fillPercent >= game.fillGoal {
		advanceLevel(game, world)
	}
}

updateFilledPercent :: proc(game: ^Game, world: ^World) {
	world.fillPercent = i32(percentFilled(game, world) * 100)
}

percentFilled :: proc(game: ^Game, world: ^World) -> f32 {
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

fillInGaps :: proc(game: ^Game, world: ^World) {
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

package yeeball

import rl "vendor:raylib"
import "core:c"
import "core:strconv"
import "core:strings"

drawOutline :: proc(game: ^Game, points: [dynamic]Point) {
	if len(points) >= 3 {
		for i := 0; i < len(points) - 1; i += 1 {
			rl.DrawLine(game.leftOffset + points[i].x, game.topOffset + points[i].y, game.leftOffset + points[i + 1].x, game.topOffset + points[i + 1].y, rl.WHITE)
		}

		//draw from last point to first point
		endIndex := len(points) - 1
		rl.DrawLine(game.leftOffset + points[endIndex].x, game.topOffset + points[endIndex].y, game.leftOffset + points[0].x, game.topOffset + points[0].y, rl.WHITE)
	}
}

drawPercentFilled :: proc(game: ^Game, world: ^World) {
	buffer: [4]byte
	buffer[0] = '0'
	buffer[1] = '0'
	buffer[2] = '%'
	buffer[3] = 0

	strconv.itoa(buffer[:], int(world.fillPercent))
	rl.DrawText(cstring(raw_data(buffer[:])), game.leftOffset + world.border, 32, 32, rl.GREEN)
}

drawLives :: proc(game: ^Game, world: ^World) {
	buffer: [20]byte
	buffer[19] = 0
	strconv.itoa(buffer[:], int(game.lives))
	rl.DrawText("Lives: ", 760, 32, 32, rl.GREEN)
	rl.DrawText(cstring(raw_data(buffer[:])), 860, 32, 32, rl.GREEN)
}

drawWorld :: proc(game: ^Game, world: ^World) {
	rl.BeginDrawing()
	{
		rl.ClearBackground(rl.BLACK)
		//rl.DrawFPS(5, 650)
		drawPercentFilled(game, world)
		drawLives(game, world)
		
		for ball in world.balls {
			rl.DrawCircleLines(game.leftOffset + c.int(ball.position.x), game.topOffset + c.int(ball.position.y), f32(game.ballRadius), rl.GREEN)
			points := getWorldOutline(world, i32(ball.position.x), i32(ball.position.y))
			drawOutline(game, points)
			defer delete(points)
		}

		if world.blueExtender.active {
			x := world.blueExtender.x + game.leftOffset
			y := world.blueExtender.y + game.topOffset
			if world.blueExtender.horizontal{
				rl.DrawRectangleLines(x, y, i32(world.blueExtender.length), game.extenderSize, rl.BLUE)
			} else {
				rl.DrawRectangleLines(x, y, game.extenderSize, i32(world.blueExtender.length), rl.BLUE)
			}
		}
		if world.redExtender.active {
			x := world.redExtender.x + game.leftOffset
			y := world.redExtender.y + game.topOffset
			length := i32(world.redExtender.length)
			if world.redExtender.horizontal {
				rl.DrawRectangleLines(x - length, y, length, game.extenderSize, rl.RED)
			} else {
				rl.DrawRectangleLines(x, y - length, game.extenderSize, length, rl.RED)
			}
		}
	}
	rl.EndDrawing()
}
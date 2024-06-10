package yeeball

import "core:strconv"
import "core:strings"
import time "core:time"
import rl "vendor:raylib"
import "core:c"
import "core:fmt"


Window :: struct {
	name:          cstring,
	width:         i32,
	height:        i32,
	fps:           i32,
	control_flags: rl.ConfigFlags,
}

Game :: struct {
	horizontal: bool,
	width: i32,
	height: i32,

	topOffset: i32,
	leftOffset: i32,

	ballRadius: i32,

	blueUsed: bool,
	redUsed: bool,

	ballSpeed: f32,
	extenderSpeed: f32,
	extenderSize: i32,
}

WorldState :: enum u8 {
	EMPTY,
	WALL,
	EXPANDING_R,
	EXPANDING_B,
}

World :: struct {
	width:  i32,
	height: i32,
	border:  i32,
	filled:  []WorldState,
	balls:  [dynamic]Ball,
	blueExtender: Extender,
	redExtender: Extender,
}

Ball :: struct {
	position: rl.Vector2,
	velocity: rl.Vector2,
}

Extender :: struct {
	x: i32,
	y: i32,
	length: f32,
	horizontal: bool,
	active: bool,
}

set_mouse :: proc(game: Game) {
	if game.horizontal {
		rl.SetMouseCursor(rl.MouseCursor.RESIZE_EW)
	} else {
		rl.SetMouseCursor(rl.MouseCursor.RESIZE_NS)
	}
}

init_world :: proc(world: ^World) {
	//Add ball
	ball := Ball{position = rl.Vector2{100, 100},velocity = rl.Vector2{1, 1}}
	append(&world.balls, ball)

	//Add border
	for y: i32 = 0; y < world.border; y += 1 {
		for x: i32 = 0; x < world.width; x += 1 {
			index := worldIndex(world, x, y)
			world.filled[index] = WorldState.WALL
		}
	}
	for y: i32 = world.height - world.border; y < world.height; y += 1 {
		for x: i32 = 0; x < world.width; x += 1 {
			index := worldIndex(world, x, y)
			world.filled[index] = WorldState.WALL
		}
	}

	for y: i32 = 0; y < world.height; y += 1 {
		for x: i32 = 0; x < world.border; x += 1 {
			index := worldIndex(world, x, y)
			world.filled[index] = WorldState.WALL
		}
		for x: i32 = world.width - world.border; x < world.width; x += 1 {
			index := worldIndex(world, x, y)
			world.filled[index] = WorldState.WALL
		}
	}
}

worldIndex :: proc(world: ^World, x, y: i32) -> i32 {
	return y * world.width + x
}

drawWorld :: proc(game: Game, world: ^World) {
	points := getWorldOutline(world, 100, 100)
	rl.BeginDrawing()
	{
		rl.ClearBackground(rl.BLACK)
		rl.DrawFPS(5, 5)
		
		if len(points) >= 3 {
			for i := 0; i < len(points) - 1; i += 1 {
				rl.DrawLine(game.leftOffset + points[i].x, game.topOffset + points[i].y, game.leftOffset + points[i + 1].x, game.topOffset + points[i + 1].y, rl.WHITE)
			}

			//draw from last point to first point
			endIndex := len(points) - 1
			rl.DrawLine(game.leftOffset + points[endIndex].x, game.topOffset + points[endIndex].y, game.leftOffset + points[0].x, game.topOffset + points[0].y, rl.WHITE)
		}

		for ball in world.balls {
			rl.DrawCircleLines(game.leftOffset + c.int(ball.position.x), game.topOffset + c.int(ball.position.y), f32(game.ballRadius), rl.GREEN)
		}

		if world.blueExtender.active {
			if world.blueExtender.horizontal == false {
				rl.DrawRectangleLines(world.blueExtender.x, world.blueExtender.y, game.extenderSize, i32(world.blueExtender.length), rl.BLUE)
			} else {
				rl.DrawRectangleLines(world.blueExtender.x, world.blueExtender.y, i32(world.blueExtender.length), game.extenderSize, rl.BLUE)
			}
		}
		if world.redExtender.active {
			length := i32(world.redExtender.length)
			if world.redExtender.horizontal == false {
				rl.DrawRectangleLines(world.redExtender.x, world.redExtender.y - length, game.extenderSize, length, rl.RED)
			} else {
				rl.DrawRectangleLines(world.redExtender.x - length, world.redExtender.y, length, game.extenderSize, rl.RED)
			}
		}
	}
	rl.EndDrawing()
}

updateWorld :: proc(game: Game, world: ^World, delta: f32) {
	for i := 0; i < len(world.balls); i += 1 {
		world.balls[i].position.x += world.balls[i].velocity.x * delta * game.ballSpeed
		world.balls[i].position.y += world.balls[i].velocity.y * delta * game.ballSpeed
		ballWallCollision(game, world, &world.balls[i])
	}

	updateExtenders(game, world, delta)
}

updateExtenders :: proc(game: Game, world: ^World, delta: f32) {
	if world.blueExtender.active {
		world.blueExtender.length += delta * game.extenderSpeed
	}
	if world.redExtender.active {
		world.redExtender.length += delta * game.extenderSpeed
	}
}

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

click :: proc(game: Game, world: ^World, x, y: i32) {
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

main :: proc() {
	window := Window{"Yeeball", 1024, 1024, 60, rl.ConfigFlags{.WINDOW_RESIZABLE}}

	game := Game {
		horizontal = true,
		width = 768 + 32,
		height = 512 + 32,
		topOffset = 100,
		leftOffset = 100,
		ballRadius = 8,
		blueUsed = false,
		redUsed = false,
		ballSpeed = 100,
		extenderSpeed = 100,
		extenderSize = 16,
	}

	world := World {
		width = game.width,
		height = game.height,
		border = 16,
		filled = make([]WorldState, game.width * game.height),
		balls = make([dynamic]Ball, 0, 16),
		blueExtender = Extender {
			length = 0,
			active = false,
		},
		redExtender = Extender {
			length = 0,
			active = false,
		}
	}
	defer delete(world.filled)
	defer delete(world.balls)

	init_world(&world)

	rl.InitWindow(window.width, window.height, window.name)
	rl.SetWindowState(window.control_flags)
	rl.SetTargetFPS(window.fps)

	set_mouse(game)

	for !rl.WindowShouldClose() {
		left_mouse_clicked := rl.IsMouseButtonPressed(.LEFT)
		right_mouse_clicked := rl.IsMouseButtonPressed(.RIGHT)
		
		if right_mouse_clicked {
			game.horizontal = !game.horizontal
			set_mouse(game)
		}

		if left_mouse_clicked {
			mousePos := rl.GetMousePosition()
			click(game, &world, i32(mousePos.x) + game.leftOffset, i32(mousePos.y) + game.topOffset)
		}

		delta := rl.GetFrameTime()

		updateWorld(game, &world, delta)
		drawWorld(game, &world)
	}

	rl.CloseWindow()
}

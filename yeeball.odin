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

	lives: i32,
	level: i32,

	fillGoal: i32,
}

EMPTY : byte : 0
WALL : byte : 1

World :: struct {
	width:  i32,
	height: i32,
	border:  i32,
	filled:  []byte,
	balls:  [dynamic]Ball,
	blueExtender: Extender,
	redExtender: Extender,
	fillPercent: i32,
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

set_mouse :: proc(game: ^Game) {
	if game.horizontal {
		rl.SetMouseCursor(rl.MouseCursor.RESIZE_EW)
	} else {
		rl.SetMouseCursor(rl.MouseCursor.RESIZE_NS)
	}
}

init_world :: proc(world: ^World) {
	//Add ball
	append(&world.balls, Ball{position = rl.Vector2{200, 200},velocity = rl.Vector2{1, 1}})
	append(&world.balls, Ball{position = rl.Vector2{100, 100},velocity = rl.Vector2{-1, 1}})

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
}

worldIndex :: proc(world: ^World, x, y: i32) -> i32 {
	return y * world.width + x
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
		ballSpeed = 200,
		extenderSpeed = 300,
		extenderSize = 16,
		lives = 2,
		level = 1,
		fillGoal = 75,
	}

	world := World {
		width = game.width,
		height = game.height,
		border = 16,
		filled = make([]byte, game.width * game.height),
		balls = make([dynamic]Ball, 0, 16),
		blueExtender = Extender {
			length = 0,
			active = false,
		},
		redExtender = Extender {
			length = 0,
			active = false,
		},
		fillPercent = 0,
	}
	defer delete(world.filled)
	defer delete(world.balls)

	init_world(&world)

	rl.InitWindow(window.width, window.height, window.name)
	rl.SetWindowState(window.control_flags)
	rl.SetTargetFPS(window.fps)

	set_mouse(&game)

	for !rl.WindowShouldClose() {
		left_mouse_clicked := rl.IsMouseButtonPressed(.LEFT)
		right_mouse_clicked := rl.IsMouseButtonPressed(.RIGHT)
		
		if right_mouse_clicked {
			game.horizontal = !game.horizontal
			set_mouse(&game)
		}

		if left_mouse_clicked {
			mousePos := rl.GetMousePosition()
			click(&game, &world, i32(mousePos.x) - game.leftOffset, i32(mousePos.y) - game.topOffset)
		}

		delta := rl.GetFrameTime()

		updateWorld(&game, &world, delta)
		drawWorld(&game, &world)
	}

	rl.CloseWindow()
}

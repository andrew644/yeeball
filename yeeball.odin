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

main :: proc() {
	window := Window{"Yeeball", 1024, 768, 60, rl.ConfigFlags{}}
	rl.SetTraceLogLevel(.ERROR)

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

	initWorld(&game, &world)

	rl.InitWindow(window.width, window.height, window.name)
	rl.SetWindowState(window.control_flags)
	rl.SetTargetFPS(window.fps)

	setMouse(&game)

	for !rl.WindowShouldClose() {
		left_mouse_clicked := rl.IsMouseButtonPressed(.LEFT)
		right_mouse_clicked := rl.IsMouseButtonPressed(.RIGHT)
		
		if right_mouse_clicked {
			game.horizontal = !game.horizontal
			setMouse(&game)
		}

		if left_mouse_clicked {
			mousePos := rl.GetMousePosition()
			x := i32(mousePos.x) - game.leftOffset
			y := i32(mousePos.y) - game.topOffset
			if isValidClick(&game, &world, x, y) {
				click(&game, &world, x, y)
			}
		}

		delta := rl.GetFrameTime()

		updateWorld(&game, &world, delta)
		drawWorld(&game, &world)
	}

	rl.CloseWindow()
}

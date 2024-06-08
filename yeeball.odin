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

	top_offset: i32,
	left_offset: i32,

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
}

set_mouse :: proc(game: Game) {
	if game.horizontal {
		rl.SetMouseCursor(rl.MouseCursor.RESIZE_EW)
	} else {
		rl.SetMouseCursor(rl.MouseCursor.RESIZE_NS)
	}
}

init_world :: proc(world: World) {
	for y: i32 = 0; y < world.border; y += 1 {
		for x: i32 = 0; x < world.width; x += 1 {
			index := world_index(world, x, y)
			world.filled[index] = WorldState.WALL
		}
	}
	for y: i32 = world.height - world.border; y < world.height; y += 1 {
		for x: i32 = 0; x < world.width; x += 1 {
			index := world_index(world, x, y)
			world.filled[index] = WorldState.WALL
		}
	}

	for y: i32 = 0; y < world.height; y += 1 {
		for x: i32 = 0; x < world.border; x += 1 {
			index := world_index(world, x, y)
			world.filled[index] = WorldState.WALL
		}
		for x: i32 = world.width - world.border; x < world.width; x += 1 {
			index := world_index(world, x, y)
			world.filled[index] = WorldState.WALL
		}
	}
}

world_index :: proc(world: World, x, y: i32) -> i32 {
	return y * world.width + x
}

draw_world :: proc(game: Game, world: World) {
	points := getWorldOutline(world, 100, 100)
	rl.BeginDrawing()
	{
		rl.ClearBackground(rl.BLACK)
		rl.DrawFPS(5, 5)
		
		if len(points) >= 3 {
			for i := 0; i < len(points) - 1; i += 1 {
				rl.DrawLine(game.left_offset + points[i].x, game.top_offset + points[i].y, game.left_offset + points[i + 1].x, game.top_offset + points[i + 1].y, rl.WHITE)
			}

			//draw from last point to first point
			endIndex := len(points) - 1
			rl.DrawLine(game.left_offset + points[endIndex].x, game.top_offset + points[endIndex].y, game.left_offset + points[0].x, game.top_offset + points[0].y, rl.WHITE)
		}
	}
	rl.EndDrawing()
}

main :: proc() {
	window := Window{"Yeeball", 1024, 1024, 60, rl.ConfigFlags{.WINDOW_RESIZABLE}}

	game := Game {
		horizontal = true,
		width = 768 + 32,
		height = 512 + 32,
		top_offset = 100,
		left_offset = 100,
	}

	world := World {
		width = game.width,
		height = game.height,
		border = 16,
		filled = make([]WorldState, game.width * game.height),
	}
	defer delete(world.filled)

	init_world(world)

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

		draw_world(game, world)
	}

	rl.CloseWindow()
}

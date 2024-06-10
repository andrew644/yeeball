package yeeball

import rl "vendor:raylib"
import "core:fmt"

@(private="file")
Direction :: enum u8 {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

Point :: struct {
	x: i32,
	y: i32,
}

getWorldOutline :: proc(world: ^World, startX, startY: i32) -> [dynamic]Point {
	// find left side
	x := startX
	y := startY
	for x >= 0 {
		index := worldIndex(world, x, y)
		if world.filled[index] == WorldState.WALL {
			break
		}
		x -= 1
	}

	points: [dynamic]Point

	dir: Direction
	x, y, dir = up(world, x, y)
	append(&points, Point{x, y})

	for {
		switch(dir) {
			case .UP:
				x, y, dir = up(world, x, y)
			case .DOWN:
				x, y, dir = down(world, x, y)
			case .LEFT:
				x, y, dir = left(world, x, y)
			case .RIGHT:
				x, y, dir = right(world, x, y)
		}
		if inPoints(points, x, y) {
			return points
		}
		append(&points, Point{x, y})
	}
}

@(private="file")
inPoints :: proc(points: [dynamic]Point, x, y: i32) -> bool {
	for i := 0; i < len(points); i += 1 {
		if points[i].x == x && points[i].y == y {
			return true
		}
	}

	return false
}

@(private="file")
up :: proc(world: ^World, startX, startY: i32) -> (i32, i32, Direction) {
	x := startX
	y := startY

	y -= 1 //move once since we know we aren't at the edge yet

	for {
		right := worldIndex(world, x + 1, y)
		up := worldIndex(world, x, y - 1) 

		if world.filled[up] == WorldState.WALL {
			if world.filled[right] == WorldState.EMPTY {
				y -= 1
				continue
			}
			if world.filled[right] == WorldState.WALL {
				return x, y, Direction.RIGHT
			}
		}

		if world.filled[up] == WorldState.EMPTY && world.filled[right] == WorldState.EMPTY {
			return x, y, Direction.LEFT
		}
	}
}

@(private="file")
left :: proc(world: ^World, startX, startY: i32) -> (i32, i32, Direction) {
	x := startX
	y := startY

	x -= 1 //move once since we know we aren't at the edge yet

	for {
		left := worldIndex(world, x - 1, y)
		up := worldIndex(world, x, y - 1) 

		if world.filled[left] == WorldState.WALL {
			if world.filled[up] == WorldState.EMPTY {
				x -= 1
				continue
			}
			if world.filled[up] == WorldState.WALL {
				return x, y, Direction.UP
			}
		}

		if world.filled[left] == WorldState.EMPTY && world.filled[up] == WorldState.EMPTY {
			return x, y, Direction.DOWN
		}
	}
}

@(private="file")
down :: proc(world: ^World, startX, startY: i32) -> (i32, i32, Direction) {
	x := startX
	y := startY

	y += 1 //move once since we know we aren't at the edge yet

	for {
		down := worldIndex(world, x, y + 1)
		left := worldIndex(world, x - 1, y) 

		if world.filled[down] == WorldState.WALL {
			if world.filled[left] == WorldState.EMPTY {
				y += 1
				continue
			}
			if world.filled[left] == WorldState.WALL {
				return x, y, Direction.LEFT
			}
		}

		if world.filled[down] == WorldState.EMPTY && world.filled[left] == WorldState.EMPTY {
			return x, y, Direction.RIGHT
		}
	}
}

@(private="file")
right :: proc(world: ^World, startX, startY: i32) -> (i32, i32, Direction) {
	x := startX
	y := startY

	x += 1 //move once since we know we aren't at the edge yet

	for {
		right := worldIndex(world, x + 1, y)
		down := worldIndex(world, x, y + 1) 

		if world.filled[right] == WorldState.WALL {
			if world.filled[down] == WorldState.EMPTY {
				x += 1
				continue
			}
			if world.filled[down] == WorldState.WALL {
				return x, y, Direction.DOWN
			}
		}

		if world.filled[right] == WorldState.EMPTY && world.filled[down] == WorldState.EMPTY {
			return x, y, Direction.UP
		}
	}
}
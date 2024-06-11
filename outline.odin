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
		if world.filled[index] == WALL {
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

		if world.filled[up] == WALL {
			if world.filled[right] == EMPTY {
				y -= 1
				continue
			}
			if world.filled[right] == WALL {
				return x, y, Direction.RIGHT
			}
		}

		if world.filled[up] == EMPTY && world.filled[right] == EMPTY {
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

		if world.filled[left] == WALL {
			if world.filled[up] == EMPTY {
				x -= 1
				continue
			}
			if world.filled[up] == WALL {
				return x, y, Direction.UP
			}
		}

		if world.filled[left] == EMPTY && world.filled[up] == EMPTY {
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

		if world.filled[down] == WALL {
			if world.filled[left] == EMPTY {
				y += 1
				continue
			}
			if world.filled[left] == WALL {
				return x, y, Direction.LEFT
			}
		}

		if world.filled[down] == EMPTY && world.filled[left] == EMPTY {
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

		if world.filled[right] == WALL {
			if world.filled[down] == EMPTY {
				x += 1
				continue
			}
			if world.filled[down] == WALL {
				return x, y, Direction.DOWN
			}
		}

		if world.filled[right] == EMPTY && world.filled[down] == EMPTY {
			return x, y, Direction.UP
		}
	}
}
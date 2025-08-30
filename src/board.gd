@tool
extends Node2D

enum Direction { UP, DOWN, LEFT, RIGHT }

const PLACEHOLDER_SCENE = preload("res://src/placeholder.tscn")
const TILE_SCENE = preload("res://src/tile.tscn")

const NEW_TILE_ANIMATION_TIME: float = 0.25
const MOVE_ANIMATION_TIME: float = 0.25

const GRID_SIZE = 4
const TILE_SPACING = 130
const TILE_OFFSET = 64

signal score_reset
signal score_increased
signal game_finished

var active: bool = true
var game_over: bool = false
var board_id: int = 0  # Used for different random spawning

var grid_tile_positions: Array[Vector2]
var tiles: Array[Tile]
var frozen_tiles: Array[RigidBody2D] = []
var cell_size: Vector2

func _ready() -> void:
	reset_game()

func _input(event: InputEvent) -> void:
	# Input is now handled by game.gd through process_input
	pass

func process_input(event: InputEvent) -> void:
	if not active or game_over:
		return
	elif event.is_action_pressed("up"):
		step_game(Direction.UP)
	elif event.is_action_pressed("down"):
		step_game(Direction.DOWN)
	elif event.is_action_pressed("left"):
		step_game(Direction.LEFT)
	elif event.is_action_pressed("right"):
		step_game(Direction.RIGHT)

func get_dynamic_tile_sizes() -> Dictionary:
	# Get the size of one grid cell
	var control_cell = $GridContainer.get_child(0)
	var cell_size = $GridContainer.size/$GridContainer.columns
	print(cell_size)
	
	return {
		1: cell_size,                                    # 1 cell
		2: Vector2(cell_size.x * 2, cell_size.y),      # 2 cells wide
		3: Vector2(cell_size.x * 3, cell_size.y),      # 3 cells wide
	}

func spawn_new_tile() -> void:
	var empty_cells = get_empty_cells()
	if empty_cells.is_empty():
		return
	
	var index = empty_cells[randi() % empty_cells.size()]
	var control_cell = $GridContainer.get_child(index)
	var tile = TILE_SCENE.instantiate()
	
	add_child(tile)
	tile.global_position = control_cell.global_position 
	tile.add_to_group("tiles")
	
	var value = randi_range(1, 3)
	tile.value = value
	
	# Set size based on grid cells
	var dynamic_sizes = get_dynamic_tile_sizes()
	tile.set_custom_size(dynamic_sizes[value])
	
	tile.freeze = true

func get_empty_cells() -> Array:
	var empty_cells = []
	
	for i in range($GridContainer.get_child_count()):
		var child = $GridContainer.get_child(i)
		
		# Skip if it's not a Control node (skip the StaticBody2D walls)
		if not child is Control:
			continue
			
		var current_cell = child
		var cell_rect = Rect2(current_cell.global_position, current_cell.size)
		
		var cell_occupied = false
		for tile in get_tree().get_nodes_in_group("tiles"):
			if cell_rect.has_point(tile.global_position):
				cell_occupied = true
				break
		
		if not cell_occupied:
			empty_cells.append(i)
	
	return empty_cells

func step_game(direction: Direction) -> void:
	# Unfreeze freshly spawned tile
	for tile in frozen_tiles:
		if tile != null:
			tile.freeze = false
	
	# Clear the list since they're all unfrozen now
	frozen_tiles.clear()
	
	match direction:
		Direction.UP: $GridContainer.rotation_degrees = 180
		Direction.DOWN: $GridContainer.rotation_degrees = 0  
		Direction.LEFT: $GridContainer.rotation_degrees = 90
		Direction.RIGHT: $GridContainer.rotation_degrees = -90
	spawn_new_tile()

func slice(index: int, direction: Direction) -> Array:
	if index < 0 or index >= GRID_SIZE:
		return []
	elif direction == Direction.UP:
		return range(index, GRID_SIZE * GRID_SIZE + index, GRID_SIZE)
	elif direction == Direction.DOWN:
		return range(GRID_SIZE * GRID_SIZE - index - 1, -1, -GRID_SIZE)
	elif direction == Direction.LEFT:
		return range(index * GRID_SIZE, index * GRID_SIZE + GRID_SIZE)
	elif direction == Direction.RIGHT:
		return range(index * GRID_SIZE + GRID_SIZE - 1, index * GRID_SIZE - 1, -1)
	else:
		return []

func reset_game():
	for tile in get_tree().get_nodes_in_group("tiles"):
		tile.queue_free()
	spawn_new_tile()
	spawn_new_tile()
	emit_signal("score_reset")
	game_over = false
	active = true

func check_game_over() -> void:
	# Disabled for continuous play
	pass

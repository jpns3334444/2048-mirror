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

var tile_positions: Array[Vector2]
var tiles: Array[Tile]

func _ready() -> void:
	tile_positions = generate_tile_positions()
	spawn_placeholders(tile_positions)
	tiles = []
	tiles.resize(GRID_SIZE * GRID_SIZE)
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

func generate_tile_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	positions.resize(GRID_SIZE * GRID_SIZE)
	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var grid_position = Vector2(TILE_OFFSET, TILE_OFFSET) + Vector2(x * TILE_SPACING, y * TILE_SPACING)
			positions[y * GRID_SIZE + x] = grid_position
	return positions

func reset_game():
	for tile in tiles:
		if tile != null:
			tile.queue_free()
	tiles.clear()
	tiles.resize(GRID_SIZE * GRID_SIZE)
	spawn_new_tile()
	spawn_new_tile()
	emit_signal("score_reset")
	game_over = false
	active = true

func get_empty_tile_position_indices() -> Array:
	var empty_indices = []
	for index in range(tiles.size()):
		if tiles[index] == null:
			empty_indices.append(index)
	return empty_indices

func spawn_placeholders(spawn_positions: Array[Vector2]) -> void:
	for position in spawn_positions:
		var placeholder = PLACEHOLDER_SCENE.instantiate()
		placeholder.position = position
		add_child(placeholder)

func spawn_new_tile() -> void:
	var empty_indices = get_empty_tile_position_indices()
	if empty_indices.is_empty():
		return
	
	var index = empty_indices[randi() % empty_indices.size()]
	var tile = TILE_SCENE.instantiate()
	tiles[index] = tile
	tile.position = $TileSpawnPoint.position
	add_child(tile)
	tile.value = randi_range(1,3)
	
	# Tile chooses its own size in _ready()
	var tween = create_tween()
	tween.tween_property(tile, "position", tile_positions[index], NEW_TILE_ANIMATION_TIME)

func step_game(direction: Direction) -> void:
	slide_tiles_no_merge(direction)
	var changed = sync_tile_positions()
	if changed: 
		spawn_new_tile()
	# No game over check for continuous play

func slide_tiles_no_merge(direction: Direction) -> void:
	# Slide tiles without merging - just move them to fill empty spaces
	for slice_index in range(GRID_SIZE):
		var indices = slice(slice_index, direction)
		var selected_tiles = []
		
		# Collect non-null tiles in order
		for index in indices:
			if tiles[index] != null:
				selected_tiles.append(tiles[index])
		
		# Clear the slice
		for index in indices:
			tiles[index] = null
		
		# Place tiles back from the direction they're sliding to
		for n in range(selected_tiles.size()):
			tiles[indices[n]] = selected_tiles[n]

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

func tiles_at(indices: Array) -> Array:
	var result = []
	for index in indices:
		var tile = tiles[index]
		if tile != null:
			result.append(tile)
	return result
	
func sync_tile_positions() -> bool:
	var changed: bool = false
	for index in range(tiles.size()):
		var tile = tiles[index]
		if tile == null:
			continue
		var new_position = tile_positions[index]
		if tile.position != new_position:
			var tween = create_tween()
			tween.tween_property(tile, "position", new_position, MOVE_ANIMATION_TIME)
			changed = true
	return changed

func get_tiles_info() -> Array:
	# Return tile information for symmetry checking
	var info = []
	for tile in tiles:
		if tile != null:
			info.append({"size": tile.value})
		else:
			info.append(null)
	return info

func clear_tile_at(index: int) -> void:
	# Clear a tile at a specific index (for symmetry matches)
	if index >= 0 and index < tiles.size() and tiles[index] != null:
		tiles[index].destroy()
		tiles[index] = null

func check_game_over() -> void:
	# Disabled for continuous play
	pass

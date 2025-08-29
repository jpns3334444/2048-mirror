@tool
extends Area2D
class_name Tile

var COLORS = {
	1: Color.hex(0x89CFF0ff),  # Light blue for size 1
	2: Color.hex(0x6495EDff),  # Cornflower blue for size 2  
	3: Color.hex(0x1E3A8Aff),  # Dark blue for size 3
}

var TILE_SIZES = {
	1: Vector2(128, 128),    # 1x1 block
	2: Vector2(256, 128),   # 2x1 block  
	3: Vector2(384, 128),   # 3x1 block
}

@export var value: int :
	set(new_value):
		value = new_value
		update()

func update() -> void:
	if TILE_SIZES.has(value):
		var tile_size = TILE_SIZES[value]
		
		# Resize the background ColorRect directly
		$Background.size = tile_size
		
		# Center the background based on its new size
		$Background.position = -tile_size / 2
		
		# Create a new collision shape with the correct size
		if $CollisionShape2D:
			var new_shape = RectangleShape2D.new()
			new_shape.size = tile_size
			$CollisionShape2D.shape = new_shape
	
	# Apply color
	if COLORS.has(value):
		$Background.color = COLORS[value]
	

func destroy() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	tween.tween_callback(queue_free)

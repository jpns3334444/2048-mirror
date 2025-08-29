@tool
extends Area2D
class_name Tile

var COLORS = {
	1: Color.hex(0x89CFF0ff),  # Light blue for size 1
	2: Color.hex(0x6495EDff),  # Cornflower blue for size 2  
	3: Color.hex(0x1E3A8Aff),  # Dark blue for size 3
}

var TILE_SIZES = {
	1: Vector2(64, 64),    # 1x1 block
	2: Vector2(128, 64),   # 2x1 block  
	3: Vector2(192, 64),   # 3x1 block
}

@export var value: int :
	set(new_value):
		value = new_value
		update()

func update() -> void:
	if TILE_SIZES.has(value):
		# Resize the background ColorRect directly
		$Background.size = TILE_SIZES[value]
		
		# Update collision shape to match
		if $CollisionShape2D and $CollisionShape2D.shape is RectangleShape2D:
			$CollisionShape2D.shape.size = TILE_SIZES[value]
	
	# Apply color
	if COLORS.has(value):
		$Background.color = COLORS[value]
	

func destroy() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	tween.tween_callback(queue_free)

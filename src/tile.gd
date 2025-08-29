@tool
extends RigidBody2D
class_name Tile

var COLORS = {
	1: Color.hex(0x89CFF0ff),  # Light blue for size 1
	2: Color.hex(0x6495EDff),  # Cornflower blue for size 2  
	3: Color.hex(0x1E3A8Aff),  # Dark blue for size 3
}

@export var value: int :
	set(new_value):
		value = new_value
		update()

func update() -> void:
	# Apply color only - size is set externally now
	if COLORS.has(value):
		$Background.color = COLORS[value]

func set_custom_size(new_size: Vector2):
	# Resize the background ColorRect directly
	$Background.size = new_size
	
	# Center the background based on its new size
	$Background.position = -new_size / 2
	$CollisionShape2D.shape.size = new_size

func destroy() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	tween.tween_callback(queue_free)

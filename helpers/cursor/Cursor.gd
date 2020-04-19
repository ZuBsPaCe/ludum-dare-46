extends Sprite

class_name Cursor

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var pos = get_viewport().get_mouse_position()
	position = pos

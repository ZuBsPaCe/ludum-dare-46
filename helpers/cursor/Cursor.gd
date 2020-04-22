extends CanvasLayer

class_name Cursor

onready var sprite := $Sprite

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var pos = get_viewport().get_mouse_position()
	sprite.position = pos
	

func change_visible(visible : bool) -> void:
	sprite.visible = visible
	

func get_position() -> Vector2:
	return sprite.position

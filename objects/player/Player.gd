extends KinematicBody2D

class_name Player

onready var light := $Light2D

func _ready() -> void:
	 pass

func _physics_process(delta: float) -> void:
	if Game.player_dead || Game.player_won:
		return
	
	var pos = get_viewport().get_mouse_position()
	var move = pos - position
	
	#var collision := move_and_collide(move)
	move_and_slide(move * 2)


func set_light_factor(light_factor : float) -> void:
	light.scale = Vector2(light_factor, light_factor)

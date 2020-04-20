extends KinematicBody2D

class_name Player

onready var light := $Light2D



const speed := 500

func _ready() -> void:
	 pass

func _physics_process(delta: float) -> void:
	if Game.player_dead || Game.player_won:
		return
	
	var pos = get_viewport().get_mouse_position()
	var move = pos - position
	
	
#	var dist = move.length()
#	var real_speed = speed
#	if dist < 100.0:
#		real_speed = speed * dist / 100.0
#
#	var collision := move_and_collide(move.normalized() * real_speed * delta)
	
	
	move_and_slide(move * 2)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if Game.check_enemy_collision(collision):
			break



func set_light_factor(light_factor : float) -> void:
	light.scale = Vector2(light_factor, light_factor)

extends KinematicBody2D

class_name Player


var collision

func _ready() -> void:
	 pass

func _physics_process(delta: float) -> void:
	var pos = get_viewport().get_mouse_position()
	var move = pos - position
	
	var collision := move_and_collide(move)
	if collision:
#		if collision.collider is Orb:
#			print("Orb Collided!")
		pass

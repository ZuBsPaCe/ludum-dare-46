extends KinematicBody2D

class_name Cthulhu

var player : Node2D
var direction := Vector2.LEFT

onready var body := $Body

const speed := 100.0
const angular_speed := deg2rad(180.0)

func _ready() -> void:
	pass
	

func init(player : Node2D):
	self.player = player
	

func _physics_process(delta: float) -> void:
	var target_vec := (player.position - position).normalized()
	
	var current_angle := direction.angle()
	var target_angle := target_vec.angle()
	var angle := 0.0
	
	if target_angle >= current_angle:
		if target_angle - current_angle < PI:
			# Raise angle
			angle = current_angle + angular_speed * delta
			if angle > target_angle:
				angle = target_angle
		else:
			# Lower angle
			current_angle += 2 * PI
			angle = current_angle - angular_speed * delta
			if angle < target_angle:
				angle = target_angle
	else:
		# target_angle is < current_angle
		if current_angle - target_angle < PI:
			# Lower angle
			angle = current_angle - angular_speed * delta
			if angle < target_angle:
				angle = target_angle
		else:
			# Raise angle
			current_angle -= 2 * PI
			angle = current_angle + angular_speed * delta
			if angle > target_angle:
				angle = target_angle
	
	direction = Vector2.RIGHT.rotated(angle) 
	rotation = direction.angle() + PI
	
	move_and_collide(direction * speed * delta)
	
	if direction.x <= 0:
		body.scale.y = 1
	else:
		body.scale.y = -1
	

extends KinematicBody2D

class_name Cthulhu

var player : Node2D
var direction := Vector2.LEFT

onready var body := $Body

const speed := 150.0
const angular_speed := deg2rad(180.0)

onready var audio := $AudioStreamPlayer

func _ready() -> void:
	audio.volume_db = -80
	#audio.play(randf() * audio.stream.get_length())
	audio.play()

func init(player : Node2D, dir : Vector2):
	self.player = player
	self.direction = dir

func _physics_process(delta: float) -> void:
	if Game.player_dead || Game.player_won:
		return
		
	var target_vec := (player.position - position).normalized()
	
	var speed_factor = Game.get_speed_factor(position)
	var factor = speed_factor
	var real_angular_speed = angular_speed * speed_factor
	var real_speed = speed * speed_factor
	
	var current_angle := direction.angle()
	var target_angle := target_vec.angle()
	var angle := 0.0
	
	if target_angle >= current_angle:
		if target_angle - current_angle < PI:
			# Raise angle
			angle = current_angle + real_angular_speed * delta
			if angle > target_angle:
				angle = target_angle
		else:
			# Lower angle
			current_angle += 2 * PI
			angle = current_angle - real_angular_speed * delta
			if angle < target_angle:
				angle = target_angle
	else:
		# target_angle is < current_angle
		if current_angle - target_angle < PI:
			# Lower angle
			angle = current_angle - real_angular_speed * delta
			if angle < target_angle:
				angle = target_angle
		else:
			# Raise angle
			current_angle -= 2 * PI
			angle = current_angle + real_angular_speed * delta
			if angle > target_angle:
				angle = target_angle
	
	direction = Vector2.RIGHT.rotated(angle) 
	rotation = direction.angle() + PI
	
	var collision := move_and_collide(direction * real_speed * delta)
	Game.check_player_collision(collision)
	
	if direction.x <= 0:
		body.scale.y = 1
	else:
		body.scale.y = -1
	
	var volume = -80.0 + factor * 120.0
	if volume > -20.0:
		volume = -20.0
	audio.volume_db = volume
	

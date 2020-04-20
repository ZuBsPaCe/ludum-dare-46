extends KinematicBody2D

class_name Sharpie

onready var spikes1 := $Spikes1
onready var spikes2 := $Spikes2
onready var body := $Body

var direction := Vector2.LEFT

const speed := 150.0

var time := 0.0

func init(dir : Vector2):
	self.direction = dir

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	time += delta
	spikes1.rotation_degrees = fmod(time * 180.0, 360.0)
	spikes2.rotation_degrees = fmod(time * 180.0 + 45.0, 360.0)
#
#func _physics_process(delta: float) -> void:
#	body.global_rotation_degrees = 0


func _physics_process(delta: float) -> void:
	var real_speed = speed * Game.get_speed_factor(position)
	
	var vec = direction * real_speed * delta
	var collision : KinematicCollision2D = null
	collision = move_and_collide(vec)
	
	if collision:
		vec = collision.remainder.bounce(collision.normal)
		direction = direction.bounce(collision.normal)
		move_and_collide(vec)


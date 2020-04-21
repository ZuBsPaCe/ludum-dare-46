extends KinematicBody2D

class_name Sharpie

onready var spikes1 := $Spikes1
onready var spikes2 := $Spikes2
onready var body := $Body

var direction := Vector2.LEFT

const speed := 150.0

var time := 0.0

onready var audio := $AudioStreamPlayer

func init(dir : Vector2):
	self.direction = dir

func _ready() -> void:
	audio.volume_db = -80
	#audio.play(randf() * audio.stream.get_length())
	audio.play()
	
func _process(delta: float) -> void:
	time += delta
	spikes1.rotation_degrees = fmod(time * 180.0, 360.0)
	spikes2.rotation_degrees = fmod(time * 180.0 + 45.0, 360.0)
#
#func _physics_process(delta: float) -> void:
#	body.global_rotation_degrees = 0


func _physics_process(delta: float) -> void:
	if Game.player_dead || Game.player_won:
		return
	
	var factor = Game.get_speed_factor(position)
	var real_speed = speed * factor
	
	var vec = direction * real_speed * delta
	var collision : KinematicCollision2D = null
	collision = move_and_collide(vec)
	
	Game.check_player_collision(collision)
	
	if collision:
		vec = collision.remainder.bounce(collision.normal)
		direction = direction.bounce(collision.normal)
		move_and_collide(vec)
	
	var volume = -80.0 + factor * 120.0
	if volume > -20.0:
		volume = -20.0
	audio.volume_db = volume


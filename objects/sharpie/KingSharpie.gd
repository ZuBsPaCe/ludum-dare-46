extends KinematicBody2D

class_name KingSharpie

onready var spikes1 := $Spikes1
onready var spikes2 := $Spikes2
onready var body := $Body

var direction := Vector2.LEFT

const speed := 80.0

var time := 0.0

onready var audio := $AudioStreamPlayer

var target := Vector2()
var dir := Vector2()
var travel := 0.0

var stop_rotation := false

func init(dir : Vector2):
	self.direction = dir

func _ready() -> void:
	restart()

func restart() -> void:
	audio.volume_db = -80
	audio.play()
	
	var x : float
	var y : float
	
	var offset := 200.0
	
	if randi() % 2 == 0:
		# Vertical
		x = randf() * 1280
		target.x = randf() * 1280
		if randi() % 2 == 0:
			y = -offset
			target.y = 720 + offset
		else:
			y = 720 + offset
			target.y = -offset
	else:
		# Horizontal
		y = randf() * 720
		target.y = randf() * 720
		if randi() % 2 == 0:
			x = -offset
			target.x = 1280 + offset
		else:
			x = 1280 + offset
			target.x = -offset
	
	position = Vector2(x, y)
	dir = target - position
	travel = dir.length()
	dir = dir.normalized()
	
func _process(delta: float) -> void:
	if stop_rotation:
		return
		
	time += delta
	spikes1.rotation_degrees = fmod(time * 180.0, 360.0)
	spikes2.rotation_degrees = fmod(time * 180.0 + 45.0, 360.0)


func _physics_process(delta: float) -> void:
	if Game.player_dead || Game.player_won:
		return
	
	var vec = dir * speed * delta
	
	var collision : KinematicCollision2D = null
	collision = move_and_collide(vec)
	
	Game.check_player_collision(collision)
	
	if Game.player_dead:
		stop_rotation = true
	
	if collision:
		vec = collision.remainder.bounce(collision.normal)
		direction = direction.bounce(collision.normal)
		move_and_collide(vec)
	
	travel -= vec.length()
	if travel <= 0:
		restart()
	
	var factor = Game.get_speed_factor(position)
	
	var volume = -80.0 + factor * 120.0
	if volume > -20.0:
		volume = -20.0
	audio.volume_db = volume


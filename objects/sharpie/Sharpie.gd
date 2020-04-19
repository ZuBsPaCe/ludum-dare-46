extends RigidBody2D

class_name Sharpie

onready var spikes1 := $Spikes1
onready var spikes2 := $Spikes2
onready var body := $Body

var time := 0.0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	time += delta
	spikes1.rotation_degrees = fmod(time * 180.0, 360.0)
	spikes2.rotation_degrees = fmod(time * 180.0 + 45.0, 360.0)
#
#func _physics_process(delta: float) -> void:
#	body.global_rotation_degrees = 0

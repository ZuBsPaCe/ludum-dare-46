extends RigidBody2D

class_name Orb

var Player := preload("res://objects/player/Player.gd")


func _ready() -> void:
	pass


func _on_Orb_body_entered(body: Node) -> void:
	if body is Player:
		Game.pickup_orb(self)

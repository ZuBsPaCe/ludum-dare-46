extends Node2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_StartButton_pressed() -> void:
	Game.change_to_game()

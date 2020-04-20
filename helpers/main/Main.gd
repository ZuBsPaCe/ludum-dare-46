extends Node2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$CanvasLayer/Highscore.text = "Highscore: " + str(Game.highscore)
	
	
	if OS.get_name() == "HTML5":
		$CanvasLayer/ExitButton.visible = false


func _on_StartButton_pressed() -> void:
	Game.change_to_game()


func _on_ExitButton_pressed() -> void:
	get_tree().quit()

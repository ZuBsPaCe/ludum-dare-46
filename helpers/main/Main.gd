extends Node2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	$CanvasLayer/Highscore.text = "Your Highscore: " + str(Game.personal_highscore)
	
	$AudioStreamPlayer.volume_db = -20
	
	$CanvasLayer/StartButton.disabled = false
	$CanvasLayer/ExitButton.disabled = false
	
	
	if OS.get_name() == "HTML5":
		$CanvasLayer/ExitButton.visible = false


func _on_StartButton_pressed() -> void:
	$CanvasLayer/StartButton.disabled = true
	$CanvasLayer/ExitButton.disabled = true
	$AnimationPlayer.play("Fadeout Music")
	Game.change_to_game()


func _on_ExitButton_pressed() -> void:
	get_tree().quit()

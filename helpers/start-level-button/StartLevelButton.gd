extends Control

signal pressed

func _ready() -> void:
	pass


func _on_Button_pressed() -> void:
	emit_signal("pressed")

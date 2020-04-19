extends Node2D

var Spawn = preload("res://helpers/spawn/Spawn.gd")
var OrbScene = preload("res://objects/orb/Orb.tscn")
var Orb = preload("res://objects/orb/Orb.gd")
var PlayerScene = preload("res://objects/player/Player.tscn")
var Player = preload("res://objects/player/Player.gd")
var CursorScene = preload("res://helpers/cursor/Cursor.tscn")
var Cursor = preload("res://helpers/cursor/Cursor.gd")

var game_started := false

var change_scene := false
var change_scene_target : String

var transitioning := false
var transitioning_to_black := true

var current_level := 1

var cursor : Cursor
var player : Player
var orb_count : int

onready var black_rect := $GUI/BlackRect
onready var animation_player := $AnimationPlayer

func _ready() -> void:
	print("Master loaded")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	cursor = CursorScene.instance()
	add_child(cursor)

func _process(delta: float) -> void:
	if transitioning:
		if animation_player.is_playing():
			return
		if transitioning_to_black:
			if change_scene:
				get_tree().change_scene(change_scene_target)
				change_scene = false
			transitioning_to_black = false
			animation_player.play("FromBlack")
			
			transitioning = false
			game_started = false
			return
	
	if game_started:
		cursor.visible = (player.position - cursor.position).length() > 18
	else:
		cursor.visible = true
	
	if !game_started:
		var scene_name := get_tree().get_current_scene().get_name()
		if scene_name.begins_with("Level"):
			start_game()
		return

func start_game() -> void:
	game_started = true
	
	var spawns := []
	_get_spawns(get_tree().get_root(), spawns)
	
	orb_count = 0
	
	var first := true
	
	for spawn in spawns:
		var instance : Node2D
		if first:
			instance = PlayerScene.instance()
			player = instance
			first = false
		else:
			instance = OrbScene.instance()
			orb_count += 1
		
		instance.position = spawn.position
		get_tree().current_scene.add_child(instance)

func won_level() -> void:
	current_level += 1
	player = null
	change_scene("Level" + str(current_level))

func change_scene(scene_name : String) -> void:
	change_scene = true
	change_scene_target = "res://scenes/" + scene_name + ".tscn"
	
	start_transition()

func start_transition() -> void:
	transitioning = true
	transitioning_to_black = true
	animation_player.play("ToBlack")

func _get_spawns(parent : Node, spawns : Array) -> void:
	for node in parent.get_children():
		if node is Spawn:
			spawns.append(node)
		else:
			_get_spawns(node, spawns)

func pickup_orb(orb : Orb) -> void:
	return
	orb.call_deferred("free")
	orb_count -= 1
	if orb_count <= 0:
		won_level()

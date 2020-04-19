extends Node2D

var Spawn = preload("res://helpers/spawn/Spawn.gd")
var OrbScene = preload("res://objects/orb/Orb.tscn")
var Orb = preload("res://objects/orb/Orb.gd")
var SharpieScene = preload("res://objects/sharpie/Sharpie.tscn")
var Sharpie = preload("res://objects/sharpie/Sharpie.gd")
var CthulhuScene = preload("res://objects/cthulhu/Cthulhu.tscn")
var Cthulhu = preload("res://objects/cthulhu/Cthulhu.gd")
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
var current_level_name := "Level1"
var level_count := 10

var cursor : Cursor
var player : Player
var orb_count : int

onready var black_rect := $GUI/BlackRect
onready var animation_player := $AnimationPlayer

var orb_init := {
	"Level1": 3,
	"Level2": 3,
	"Level3": 4,
	"Level4": 4,
	"Level5": 5,
	"Level6": 5,
	"Level7": 6,
	"Level8": 6,
	"Level9": 7,
	"Level10": 7
}

var sharpie_init := {
	"Level1": 3,
	"Level2": 3,
	"Level3": 4,
	"Level4": 4,
	"Level5": 5,
	"Level6": 5,
	"Level7": 6,
	"Level8": 6,
	"Level9": 7,
	"Level10": 7
}


var cthulhu_init := {
	"Level1": 1,
	"Level2": 1,
	"Level3": 1,
	"Level4": 2,
	"Level5": 2,
	"Level6": 3,
	"Level7": 3,
	"Level8": 4,
	"Level9": 4,
	"Level10": 4
}


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
	var sharpie_count = 0
	var cthulhu_count = 0
	
	var first := true
	
	spawns.shuffle()
	
	for spawn in spawns:
		var instance : Node2D
		if first:
			instance = PlayerScene.instance()
			player = instance
			first = false
		elif orb_count < orb_init[current_level_name]:
			instance = OrbScene.instance()
			orb_count += 1
		elif sharpie_count < sharpie_init[current_level_name]:
			instance = SharpieScene.instance()
			var sharpie := instance as Sharpie
			var dir := spawn.direction as Vector2
			if dir == Vector2.ZERO:
				dir = Vector2.UP.rotated(deg2rad(rand_range(0, 360)))
			
			sharpie.apply_impulse(Vector2.ZERO, dir * 100)
			sharpie_count += 1
		elif cthulhu_count < cthulhu_init[current_level_name]:
			instance = CthulhuScene.instance()
			var cthulhu := instance as Cthulhu
			cthulhu.init(player)
			cthulhu_count += 1
		else:
			break
		
		instance.position = spawn.position
		get_tree().current_scene.add_child(instance)

func won_level() -> void:
	current_level += 1
	current_level_name = "Level" + str(current_level)
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

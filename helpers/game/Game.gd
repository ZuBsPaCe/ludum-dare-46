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

var fame := 0
var fame_timer := 0.0

var cursor : Cursor
var player : Player
var orb_count : int

var player_position : Vector2
var player_light_radius := 0.0
var player_light_factor := 1.0
var player_dead := false
var player_won := false


var highscore := 0


onready var black_rect := $GUI/BlackRect
onready var animation_player := $AnimationPlayer
onready var info := $GUI/Info

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
	
	load_highscore()

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
				if !change_scene_target.begins_with("Level"):
					$GUI.layer = 1
					info.visible = false
					
			transitioning_to_black = false
			animation_player.play("FromBlack")
			
			transitioning = false
			game_started = false
			return
	
	if game_started:
		cursor.visible = (player.position - cursor.position).length() > 18
		player_position = player.position
		
		fame_timer += delta
		while fame_timer > 1.0:
			fame_timer -= 1.0
			fame -= 1
			if fame < 0:
				fame = 0
		
	else:
		cursor.visible = true
	
	if !game_started:
		var scene_name := get_tree().get_current_scene().get_name()
		if scene_name.begins_with("Level"):
			start_game()
		return
	
	info.text = "Orbs " + str(orb_count) + "\n" + "Fame " + str(fame)

func start_game() -> void:
	game_started = true
	player_dead = false
	player_won = false
	
	fame_timer = 0.0
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	$GUI.layer = 100
	info.visible = true
	info.text = ""
	
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
			player_position = spawn.position
			Input.warp_mouse_position(player_position)
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
			sharpie.init(dir)
			sharpie_count += 1
		elif cthulhu_count < cthulhu_init[current_level_name]:
			instance = CthulhuScene.instance()
			var cthulhu := instance as Cthulhu
			var dir := spawn.direction as Vector2
			if dir == Vector2.ZERO:
				dir = Vector2.UP.rotated(deg2rad(rand_range(0, 360)))
			cthulhu.init(player, dir)
			cthulhu_count += 1
		else:
			break
		
		instance.position = spawn.position
		get_tree().current_scene.add_child(instance)
	
	
	player_light_radius = 128.0 * player.scale.x
	player_light_factor = 1.0

func won_level() -> void:
	player_won = true
	current_level += 1
	current_level_name = "Level" + str(current_level % level_count)
	player = null
	change_scene(current_level_name)

func lost_level() -> void:
	player = null
	change_to_highscore()

func change_scene(scene_name : String) -> void:
	change_scene = true
	change_scene_target = "res://scenes/" + scene_name + ".tscn"
	
	start_transition()

func change_to_game() -> void:
	current_level = 1
	current_level_name = "Level1"
	fame = 0
	fame_timer = 0
	
	player = null
	change_scene(current_level_name)

func change_to_main() -> void:
	
	if fame > highscore:
		highscore = fame
		save_highscore()
		
	player = null
	change_scene("Main")

func change_to_highscore() -> void:
	player = null
	change_scene("Highscore")

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
	orb.call_deferred("free")
	orb_count -= 1
	
	fame += 10
	fame_timer = 0
	
	player_light_radius += 32* player.scale.x
	player_light_factor = player_light_radius / (128.0 * player.scale.x)
	player.set_light_factor(player_light_factor)
	
	if orb_count <= 0:
		won_level()

func check_player_collision(collision : KinematicCollision2D) -> void:
	if collision != null && collision.collider is Player:
		player_dead = true
		change_to_main()

func check_enemy_collision(collision : KinematicCollision2D) -> bool:
	if collision != null && (collision.collider is Sharpie || collision.collider is Cthulhu):
		player_dead = true
		change_to_main()
		return true
	return false

func get_speed_factor(position : Vector2) -> float:
	var max_move_distance = player_light_radius + 32.0
	var min_move_distance = 64.0
	
	var player_dist = (Game.player_position - position).length()
	
	if player_dist >= max_move_distance:
		return 0.0
	
	if player_dist <= min_move_distance:
		return 1.0
	
	return (max_move_distance - player_dist) / (max_move_distance - min_move_distance)


func save_highscore():
	var f = File.new()
	f.open("user://score.save", File.WRITE)
	f.store_var(highscore)
	f.close()

func load_highscore():
	var f = File.new()
	if f.file_exists("user://score.save"):
		f.open("user://score.save", File.READ)
		highscore = f.get_var()
		f.close()

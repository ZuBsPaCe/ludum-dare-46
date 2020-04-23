extends Node2D

var Spawn = preload("res://helpers/spawn/Spawn.gd")
var OrbScene = preload("res://objects/orb/Orb.tscn")
var Orb = preload("res://objects/orb/Orb.gd")
var SharpieScene = preload("res://objects/sharpie/Sharpie.tscn")
var Sharpie = preload("res://objects/sharpie/Sharpie.gd")
var KingSharpieScene = preload("res://objects/sharpie/KingSharpie.tscn")
var KingSharpie = preload("res://objects/sharpie/KingSharpie.gd")
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

var player : Player
var orb_count : int

var player_position : Vector2
var player_light_radius := 0.0
var player_light_factor := 1.0
var player_dead := false
var player_won := false


var personal_highscore := 0
var personal_highscore_broken := false
var highscore_id := 0
var nickname := "Player"
var client_id := 0

var wait_for_start_level_button := false
var wait_for_start_level_button_timer := 0.0
var spawns := []

onready var black_rect := $GUI/BlackRect
onready var animation_player := $AnimationPlayer
onready var info := $GUI/Info
onready var start_level_button := $GUI/StartLevelButton
onready var cursor := $Cursor

var start_game_counter := 0
var show_pickup_orbs_hint := true

const min_nickname_size := 3
const max_nickname_size := 16

var orb_init := {
	"Level1": 3,
	"Level2": 3,
	"Level3": 4,
	"Level4": 4,
	"Level5": 4,
	"Level6": 5,
	"Level7": 5,
	"Level8": 5,
	"Level9": 6,
	"Level10": 6
}

var sharpie_init := {
	"Level1": 3,
	"Level2": 3,
	"Level3": 3,
	"Level4": 4,
	"Level5": 4,
	"Level6": 4,
	"Level7": 5,
	"Level8": 5,
	"Level9": 5,
	"Level10": 5
}


var cthulhu_init := {
	"Level1": 1,
	"Level2": 1,
	"Level3": 1,
	"Level4": 1,
	"Level5": 2,
	"Level6": 2,
	"Level7": 2,
	"Level8": 2,
	"Level9": 3,
	"Level10": 3
}


func _ready() -> void:
	print("Master loaded")
	
	load_highscore()
	
	$GUI/BlackRect.visible = false
	$GUI/Tip.visible = false
	$GUI/Info.visible = false
	$GUI/Intro1.visible = false
	$GUI/Intro2.visible = false
	$GUI/Intro3.visible = false
	$GUI/Intro3a.visible = false
	$GUI/Intro3b.visible = false
	
	
func _input(event):
	if animation_player.is_playing() && animation_player.current_animation == "Intro" && event.is_pressed():
		animation_player.stop()
		$GUI/Info.visible = false
		$GUI/Intro1.visible = false
		$GUI/Intro2.visible = false
		$GUI/Intro3.visible = false
		$GUI/Intro3a.visible = false
		$GUI/Intro3b.visible = false
		$IntroAnimSound.stop()
		$Cursor/Sprite.visible = true
	
	if event.is_action_pressed("toggle_fullscreen") && OS.get_name() != "HTML5":
		OS.window_fullscreen = !OS.window_fullscreen
		
		
func _process(delta: float) -> void:
	info.text = "Orbs " + str(orb_count) + "\n" + "Fame " + str(fame)
	
	if transitioning:
		if animation_player.is_playing():
			return
		if transitioning_to_black:
			if change_scene:
				get_tree().change_scene(change_scene_target)
				change_scene = false
				if change_scene_target.find("Level") < 0:
					#$GUI.layer = 1
					animation_player.play("FromBlack")
					info.visible = false
				else:
					wait_for_start_level_button = true
					wait_for_start_level_button_timer = 4.0
					
			transitioning_to_black = false
			
			transitioning = false
			game_started = false
			return
	

	
	if wait_for_start_level_button:
		if start_level_button.visible == false:
			spawns = []
			_get_spawns(get_tree().get_root(), spawns)
			spawns.shuffle()
			
			var button = start_level_button.get_node("Button")
			
			if current_level == 1:
				button.text = "Click Me"
			elif current_level == 11:
				button.text = "Run!"
			elif current_level == 21:
				button.text = "Are you serious?"
			elif current_level == 31:
				button.text = "Cheater..."
			elif current_level == 41:
				button.text = "Please stop!"
			elif current_level == 51:
				button.text = "Ok. You've won! :)"
			elif current_level > level_count:
				var motivations = [
					"Really?", "How?", "LOL", "I'm afraid",
					"Erm...", "No way", "OMG", "Please no",
					"Nooo!", "Are you sure?", "Watch out", "What?",
					"Does it ever end?", "Take a break", 
					"Hell", "Ouch!", "Oh dear..", "Watch out!",
					"Impossible", "..."]
				button.text = motivations[randi() % motivations.size()]
			else:
				var motivations = [
					"Alright!", "Wow!", "Good Job", "Cool",
					"Nice!", "Hell Yeah", "Great", "Let's go",
					"Just do it", "Awesome", "Bingo", "Too easy",
					"You own", "Well done", "Top-Notch", "Epic", "Solid",
					"Perfect", "Excellent"]
				button.text = motivations[randi() % motivations.size()]
			
			start_level_button.visible = true
			start_level_button.set_position(spawns[0].position)
			$GUI/StartLevelButton/Button.visible = true
		
		
		if wait_for_start_level_button_timer > 0:
			wait_for_start_level_button_timer -= delta
			if wait_for_start_level_button_timer <= 0:
				start_level_button.get_node("Button").text = "Click Me"
				
		return
		
	else:
		if start_level_button.visible:
			start_level_button.visible = false
			animation_player.play("FromBlack")
	
	if game_started:
		cursor.change_visible((player.position - cursor.get_position()).length() > 18)
		player_position = player.position
		
		fame_timer += delta
		while fame_timer > 1.0:
			fame_timer -= 1.0
			fame -= 1
			if fame < 0:
				fame = 0
		
	else:
		cursor.change_visible(true)
	
	if !game_started:
		var scene_name := get_tree().get_current_scene().get_name()
		if scene_name.begins_with("Level"):
			info.visible = false
			start_game()
		return


func start_game() -> void:
	if !game_started && !$GameMusic1.playing && !$GameMusic2.playing:
		if (current_level-1) % level_count < 5:
			$GameMusic1.play()
		else:
			$GameMusic2.play()
			
	
	game_started = true
	player_dead = false
	player_won = false
	
	fame_timer = 0.0
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	#$GUI.layer = 100
	info.visible = true
	info.text = ""
	
	orb_count = 0
	var sharpie_count = 0
	var cthulhu_count = 0
	
	var first := true
	
	var more = current_level / level_count
	
	for spawn in spawns:
		var instance : Node2D = null
		if first:
			instance = PlayerScene.instance()
			player = instance
			player_position = spawn.position
			#Input.warp_mouse_position(player_position)
			start_level_button.set_global_position(player_position)
			start_level_button.visible = true
			first = false
		elif orb_count < orb_init[current_level_name] + more:
			instance = OrbScene.instance()
			orb_count += 1
		elif cthulhu_count < cthulhu_init[current_level_name] + more && (spawn.position - player.position).length() > 250:
			instance = CthulhuScene.instance()
			var cthulhu := instance as Cthulhu
			var dir := spawn.direction as Vector2
			if dir == Vector2.ZERO:
				dir = Vector2.UP.rotated(deg2rad(rand_range(0, 360)))
			cthulhu.init(player, dir)
			cthulhu_count += 1
		elif sharpie_count < sharpie_init[current_level_name] + more:
			instance = SharpieScene.instance()
			var sharpie := instance as Sharpie
			var dir := spawn.direction as Vector2
			if dir == Vector2.ZERO:
				dir = Vector2.UP.rotated(deg2rad(rand_range(0, 360)))
			sharpie.init(dir)
			sharpie_count += 1
		else:
			break
		
		if instance != null:
			instance.position = spawn.position
			get_tree().current_scene.add_child(instance)
	
	var king_sharpie_counter = current_level
	while king_sharpie_counter > 10:
		var king_sharpie = KingSharpieScene.instance()
		king_sharpie.init()
		get_tree().current_scene.add_child(king_sharpie)
		king_sharpie_counter -= 10
	
	player_light_radius = 128.0 * player.scale.x
	player_light_factor = 1.0

func won_level() -> void:
	player_won = true
	current_level += 1
	
	var real_level = current_level
	while real_level > level_count:
		real_level -= level_count
	
	current_level_name = "Level" + str(real_level)
	player = null
	spawns = []
	
	show_pickup_orbs_hint = false
	
	change_scene(current_level_name)

func lost_level() -> void:
	player = null
	spawns = []
	
	change_to_highscore()

func change_scene(scene_name : String) -> void:
	change_scene = true
	change_scene_target = "res://scenes/" + scene_name + ".tscn"
	
	if scene_name == "Highscore":
		start_transition_slow()
	elif scene_name == "Main":
		start_transition()
	elif current_level == 1 && start_game_counter == 1:
		start_custom_transition("Intro")
		$IntroAnimSound.play()
	elif current_level == 1 && start_game_counter > 1:
		var tips := [
			"Godot is awesome.",
			"Keep distance.",
			"Sometimes death is unfair.",
			"Monsters are attracted to light.",
			"Eating orbs is good for small lights.",
			"Stay away from monsters.",
			"Sometimes slowing down helps.",
			"The round monster is called Sharpie.",
			"The triangular monster is called Cthulhu.",
			"Some monsters can pass through walls.",
			"Dangers can be heard.",
			"If you see King Sharpie: run.",
			"Nobody knows where they came from."]
		
		var tip = tips[randi() % tips.size()]
		
		if show_pickup_orbs_hint:
			tip = "Pick up all white orbs."
		
		$GUI/Tip.text = tip
		start_custom_transition("ToBlackWithTip")
	else:
		start_transition()

func change_to_game() -> void:
	current_level = 1
	current_level_name = "Level1"
	fame = 0
	fame_timer = 0
	spawns = []
	
	start_game_counter += 1
	
	player = null
	change_scene(current_level_name)
	
	start_highscore()

func change_to_main() -> void:
	$GameMusic1.stop()
	$GameMusic2.stop()
	#$DeathSound.play()
	
	#if fame > personal_highscore:
	#	personal_highscore = fame
	#	save_highscore()
		
	player = null
	change_scene("Main")

func change_to_highscore() -> void:
	$GameMusic1.stop()
	$GameMusic2.stop()
	$DeathSound.play()
	
	if fame > personal_highscore:
		personal_highscore = fame
		personal_highscore_broken = personal_highscore > 0
		save_highscore()
	else:
		personal_highscore_broken = false
	
	stop_highscore()
	
	player = null
	change_scene("Highscore")

func start_transition() -> void:
	transitioning = true
	transitioning_to_black = true
	animation_player.play("ToBlack")

func start_custom_transition(animation : String) -> void:
	transitioning = true
	transitioning_to_black = true
	animation_player.play(animation)

func start_transition_slow() -> void:
	transitioning = true
	transitioning_to_black = true
	animation_player.play("ToBlackSlow")

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
	
	player.pickup_sound()
	
	if orb_count <= 0:
		won_level()

func check_player_collision(collision : KinematicCollision2D) -> void:
	if collision != null && collision.collider is Player:
		player_dead = true
		change_to_highscore()

func check_enemy_collision(collision : KinematicCollision2D) -> bool:
	if collision != null:
		if collision.collider is Cthulhu:
			player_dead = true
			change_to_highscore()
			return true
		
		if collision.collider is Sharpie:
			var sharpie = collision.collider as Sharpie
			sharpie.stop_rotation = true
			player_dead = true
			change_to_highscore()
			return true
		
		if collision.collider is KingSharpie:
			var king_sharpie = collision.collider as KingSharpie
			king_sharpie.stop_rotation = true
			player_dead = true
			change_to_highscore()
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
	f.open("user://settings.save", File.WRITE)
	f.store_var(personal_highscore)
	f.store_var(nickname)
	f.store_var(client_id)
	
	if OS.get_name() != "HTML5":
		f.store_var(OS.window_fullscreen)
		f.store_var(OS.window_size)
	else:
		f.store_var(false)
		f.store_var(OS.window_size)
	
	f.close()

func load_highscore():
	var f = File.new()
	if f.file_exists("user://settings.save"):
		f.open("user://settings.save", File.READ)
		personal_highscore = f.get_var()
		nickname = f.get_var()
		client_id = f.get_var()
		
		if OS.get_name() != "HTML5":
			var fullscreen = f.get_var()
			var window_size = f.get_var()
			
			if !fullscreen:
				OS.window_fullscreen = false
				OS.window_size = window_size
		
		f.close()
	else:
		client_id = randi()
		save_highscore()


func _on_StartLevelButton_pressed() -> void:
	wait_for_start_level_button = false
	

func start_highscore() -> void:
	highscore_id = 0
	
	if nickname.to_lower() == "player" || nickname.length() < min_nickname_size || nickname.length() > max_nickname_size:
		return
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_start_highscore_completed")
	
	var error = http_request.request("https://www.zubspace.com/highscore/start?client=%s&game=living-light&player=%s" % [client_id, nickname.percent_encode()])
	if error != OK:
		print("Start highscore error")


# Called when the HTTP request is completed.
func _start_highscore_completed(result, response_code, headers, body):
	
	if response_code != 200:
		return
	
	#var container = $CanvasLayer/ScrollContainer/VBoxContainer
	var response = parse_json(body.get_string_from_utf8())
	
	highscore_id = response.Id

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	#print(response.headers["User-Agent"])
	
func stop_highscore() -> void:
	if highscore_id == 0:
		return
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var id := 0
	if fame < 100:
		id = highscore_id
	else:
		# Please don't cheat. Thank you :)
		id = highscore_id/2 + (highscore_id % (fame + current_level))
	
	var error = http_request.request("https://www.zubspace.com/highscore/stop?client=%s&game=living-light&level=%s&player=%s&id=%s&score=%s" % [client_id, current_level, nickname.percent_encode(), id, fame])
	if error != OK:
		print("Stop highscore error")


extends Node2D

var HighscoreEntry := preload("res://helpers/highscore/HighscoreEntry.tscn")

onready var nickname_input := $CanvasLayer/Nickname

var do_scroll_dynamic := 0
var do_scroll_alltime := 0


var dynamic_fetched := false
var dynamic_has_values := false
var alltime_fetched := false
var alltime_has_values := false
var alltime_has_fame := false


var player_entries := []


func _ready() -> void:
	
	$CanvasLayer/ScoreLabel.text = "Score: %s  Level: %s" % [Game.fame, Game.current_level]
	$"CanvasLayer/New Personal Highscore".visible = Game.personal_highscore_broken
	$"CanvasLayer/New Online Highscore".visible = false
	$"CanvasLayer/DynamicButton".visible = false
	$"CanvasLayer/AlltimeButton".visible = false
	$CanvasLayer/ScrollContainerDynamic.visible = false
	$CanvasLayer/ScrollContainerAlltime.visible = false
	
	$CanvasLayer/NicknameLabel.visible = false
	$CanvasLayer/Nickname.visible = false
	$CanvasLayer/Nickname.text = Game.nickname
	
	
	_check_nickname()
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_get_dynamic_results_completed")
	http_request.request(Game.base_url + "/highscore/list-dynamic?client=%s&game=living-light" % Game.client_id)

	var http_request2 = HTTPRequest.new()
	add_child(http_request2)
	http_request2.connect("request_completed", self, "_get_alltime_results_completed")
	http_request2.request(Game.base_url + "/highscore/list-alltime?client=%s&game=living-light" % Game.client_id)

func _get_dynamic_results_completed(result, response_code, headers, body):
	dynamic_fetched = true
	
	if response_code != 200:
		return
	
	var container = $CanvasLayer/ScrollContainerDynamic/VBoxContainer
	var response = parse_json(body.get_string_from_utf8())

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	#print(response.headers["User-Agent"])
	
	if response == null || response.get("Name") == null || response.Name == "" || response.get("Players") == null || response.Players.size() == 0:
		return
	
	$CanvasLayer/DynamicButton.text = response.Name
	
	var entry := HighscoreEntry.instance()
	entry.get_node("Rank").text = "Rank"
	entry.get_node("Name").text = "Name"
	entry.get_node("Level").text = "Level"
	entry.get_node("Score").text = "Score"
	
	container.add_child(entry)
	
	var count = response.Players.size()
	do_scroll_dynamic = 0
	
	for i in range(count):
		entry = HighscoreEntry.instance()
		
		var player = response.Players[i]
		player = player.strip_escapes().strip_edges()
		
		entry.get_node("Rank").text = str(i + 1)
		entry.get_node("Name").text = player
		entry.get_node("Level").text = str(response.Levels[i])
		entry.get_node("Score").text = str(response.Scores[i])
		
#		if response.Rookies[i] == 1:
#			entry.get_node("Name").modulate = Color(1, 1, 1, 0.75)
		
		container.add_child(entry)
		
		if do_scroll_dynamic == 0 && response.Players[i] == Game.nickname && response.Scores[i] == Game.fame && response.Levels[i] == Game.current_level:
			do_scroll_dynamic = i
			entry.get_node("Rank").modulate = Color.green
			entry.get_node("Name").modulate = Color.green
			entry.get_node("Level").modulate = Color.green
			entry.get_node("Score").modulate = Color.green
			
			player_entries.append(entry)
			
			if Game.fame > 0:
				$"CanvasLayer/New Online Highscore".visible = true
	
	do_scroll_dynamic -= 5
	
	dynamic_has_values = true
	
	_try_show_scores()

func _get_alltime_results_completed(result, response_code, headers, body):
	alltime_fetched = true
	
	if response_code != 200:
		return
	
	var container = $CanvasLayer/ScrollContainerAlltime/VBoxContainer
	var response = parse_json(body.get_string_from_utf8())

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	#print(response.headers["User-Agent"])
	
	if response == null || response.get("Name") == null || response.Name == "" || response.get("Players") == null || response.Players.size() == 0:
		return
	
	var entry := HighscoreEntry.instance()
	entry.get_node("Rank").text = "Rank"
	entry.get_node("Name").text = "Name"
	entry.get_node("Level").text = "Level"
	entry.get_node("Score").text = "Score"
	
	container.add_child(entry)
	
	var count = response.Players.size()
	do_scroll_alltime = 0
	
	for i in range(count):
		entry = HighscoreEntry.instance()
		
		var player = response.Players[i]
		player = player.strip_escapes().strip_edges()
		
		entry.get_node("Rank").text = str(i + 1)
		entry.get_node("Name").text = player
		entry.get_node("Level").text = str(response.Levels[i])
		entry.get_node("Score").text = str(response.Scores[i])
		
#		if response.Rookies[i] == 1:
#			entry.get_node("Name").modulate = Color(1, 1, 1, 0.75)
		
		container.add_child(entry)
		
		if do_scroll_alltime == 0 && response.Players[i] == Game.nickname && response.Scores[i] == Game.fame && response.Levels[i] == Game.current_level:
			do_scroll_alltime = i
			entry.get_node("Rank").modulate = Color.green
			entry.get_node("Name").modulate = Color.green
			entry.get_node("Level").modulate = Color.green
			entry.get_node("Score").modulate = Color.green
			
			player_entries.append(entry)
			
			if Game.fame > 0:
				$"CanvasLayer/New Online Highscore".visible = true
				alltime_has_fame = true
	
	do_scroll_alltime -= 5
	
	alltime_has_values = true
	
	_try_show_scores()


func _try_show_scores():
	if !alltime_fetched || !dynamic_fetched:
		return
	
	$CanvasLayer/AlltimeButton.visible = alltime_has_values
	$CanvasLayer/DynamicButton.visible = dynamic_has_values
	
	$CanvasLayer/NicknameLabel.visible = true
	$CanvasLayer/Nickname.visible = true
	
	if alltime_has_fame:
		_show_alltime()
	elif alltime_has_values && !dynamic_has_values:
		_show_alltime()
	elif dynamic_has_values:
		_show_dynamic()

func _show_alltime():
	$CanvasLayer/DynamicButton.modulate = Color(1, 1, 1, 0.5)
	$CanvasLayer/ScrollContainerDynamic.visible = false
	
	$CanvasLayer/AlltimeButton.modulate = Color.white
	$CanvasLayer/ScrollContainerAlltime.visible = true

func _show_dynamic():
	$CanvasLayer/AlltimeButton.modulate = Color(1, 1, 1, 0.5)
	$CanvasLayer/ScrollContainerAlltime.visible = false
	
	$CanvasLayer/DynamicButton.modulate = Color.white
	$CanvasLayer/ScrollContainerDynamic.visible = true


func _on_DynamicButton_pressed() -> void:
	_show_dynamic()


func _on_AlltimeButton_pressed() -> void:
	_show_alltime()
	

func _process(delta: float) -> void:
	if do_scroll_dynamic > 0:
		
		$CanvasLayer/ScrollContainerDynamic.scroll_vertical = do_scroll_dynamic * (22 + 4)
		$CanvasLayer/ScrollContainerDynamic.update()
		
		do_scroll_dynamic = 0
	
	if do_scroll_alltime > 0:
		
		$CanvasLayer/ScrollContainerAlltime.scroll_vertical = do_scroll_alltime * (22 + 4)
		$CanvasLayer/ScrollContainerAlltime.update()
		
		do_scroll_alltime = 0



func _on_ContinueButton_pressed() -> void:
	var nickname_changed = Game.nickname != nickname_input.text
	Game.nickname = nickname_input.text
	Game.save_highscore()
	
	Game.change_to_main()
	
	if nickname_changed:
		var http_request = HTTPRequest.new()
		add_child(http_request)
		
		var error = http_request.request(Game.base_url + "/highscore/set-player-name?client=%s&game=living-light&player=%s" % [Game.client_id, Game.nickname.percent_encode()])
		if error != OK:
			print("SetPlayerName error")


func _check_nickname():
	if nickname_input.text.length() >= Game.max_nickname_size:
		var col = nickname_input.cursor_get_column()
		nickname_input.text = nickname_input.text.substr(0, Game.max_nickname_size)
		if col > Game.max_nickname_size:
			col = Game.max_nickname_size
		nickname_input.cursor_set_column(col)
	
	if !Game.check_nickname(nickname_input.text):
		$CanvasLayer/ContinueButton.disabled = true
	else:
		$CanvasLayer/ContinueButton.disabled = false

func _on_Nickname_text_changed() -> void:
	_check_nickname()
	
	for entry in player_entries:
		entry.get_node("Name").text = nickname_input.text
	

func _on_Nickname_gui_input(event: InputEvent) -> void:
	if !event.is_action_pressed("input_clicked"):
		return
	
	if OS.get_name() != "HTML5" || !OS.has_feature('JavaScript') || !OS.has_touchscreen_ui_hint():
		return
	
	# https://godotengine.org/qa/58927/virtual-keyboard-workaround-in-html5?show=58996#c58996
	var entered = JavaScript.eval(
		"prompt('%s', '%s');" % ["Your nickname:", nickname_input.text], 
		true)
	
	if entered != null && entered.length() >= Game.min_nickname_size:
		if entered.length() >= Game.max_nickname_size:
			entered = entered.substr(0, Game.max_nickname_size)
		nickname_input.text = entered
	
	_check_nickname()

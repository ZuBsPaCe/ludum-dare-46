extends Node2D

var HighscoreEntry := preload("res://helpers/highscore/HighscoreEntry.tscn")

onready var nickname_input := $CanvasLayer/Nickname

var do_scroll := 0

func _ready() -> void:
	
	$CanvasLayer/ScoreLabel.text = "Score: %s" % Game.fame
	$"CanvasLayer/New Personal Highscore".visible = Game.personal_highscore_broken
	$"CanvasLayer/New Online Highscore".visible = false
	$"CanvasLayer/GlobalLabel".visible = false
	$CanvasLayer/Nickname.text = Game.nickname
	
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	
	# Perform the HTTP request. The URL below returns some JSON as of writing.
	var error = http_request.request("https://www.zubspace.com/highscore/list-alltime?game=living-light")
	if error != OK:
		Game.switch_to_main()
		#push_error("An error occurred in the HTTP request.")


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	
	if response_code != 200:
		return
	
	var container = $CanvasLayer/ScrollContainer/VBoxContainer
	var response = parse_json(body.get_string_from_utf8())

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	#print(response.headers["User-Agent"])
	
	if response == null || response.Players == null || response.Players.size() == 0:
		$CanvasLayer/GlobalLabel.visible = false
		$CanvasLayer/ScrollContainer.visible = false
		return
	
	$"CanvasLayer/GlobalLabel".visible = true
	var entry := HighscoreEntry.instance()
	entry.get_node("Rank").text = "Rank"
	entry.get_node("Name").text = "Name"
	entry.get_node("Level").text = "Level"
	entry.get_node("Score").text = "Score"
	
	container.add_child(entry)
	
	var count = response.Players.size()
	do_scroll = 0
	
	for i in range(count):
		entry = HighscoreEntry.instance()
		
		var player = response.Players[i]
		player = player.strip_escapes().strip_edges()
		
		if player.to_lower() == "zubspace":
			continue
		
		entry.get_node("Rank").text = str(i + 1)
		entry.get_node("Name").text = player
		entry.get_node("Level").text = str(response.Levels[i])
		entry.get_node("Score").text = str(response.Scores[i])
		
		container.add_child(entry)
		
		if do_scroll == 0 && response.Players[i] == Game.nickname && response.Scores[i] == Game.fame && response.Levels[i] == Game.current_level:
			do_scroll = i
			entry.get_node("Rank").modulate = Color.green
			entry.get_node("Name").modulate = Color.green
			entry.get_node("Level").modulate = Color.green
			entry.get_node("Score").modulate = Color.green
			
			if Game.fame > 0:
				$"CanvasLayer/New Online Highscore".visible = true
	
	do_scroll -= 5
	

func _process(delta: float) -> void:
	if do_scroll > 0:
		
		$CanvasLayer/ScrollContainer.scroll_vertical = do_scroll * (22 + 4)
		$CanvasLayer/ScrollContainer.update()
		
		do_scroll = 0



func _on_ContinueButton_pressed() -> void:
	
	Game.nickname = nickname_input.text
	Game.save_highscore()
	
	Game.change_to_main()


func _on_Nickname_text_changed() -> void:
	if nickname_input.text.length() >= 12:
		var col = nickname_input.cursor_get_column()
		nickname_input.text = nickname_input.text.substr(0, 12)
		if col > 12:
			col = 12
		nickname_input.cursor_set_column(col)
		


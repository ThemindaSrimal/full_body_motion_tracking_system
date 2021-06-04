#handle scene in game
extends Node



var current_scene = null
var scene_stack = []

var is_playing = false

onready var scene_map = {
	"mainmenu":preload("res://Scenes/InterfaceScenes/MainMenuLayer.tscn"),
	"loginmenu":preload("res://Scenes/InterfaceScenes/LoginScreen.tscn"),
	"settings":preload("res://Scenes/InterfaceScenes/SettingsScreen.tscn"),
	"pausemenu":preload("res://Scenes/InterfaceScenes/PauseMenuScreen.tscn")
	}

onready var popbox = $PopBox
onready var infoscreen = $InfoScreen
onready var map = $Map


func _ready():
	
	#current_scene = scene_map["mainmenu"]
	_change_scene("mainmenu")
	#initiate game here
	#start pplaying background sound
	play_background_sound()
	#var mapstart_instance = mapstart.instance()
	#add_child(mapstart_instance)
	#mapstart_instance.get_node("GUI/PlayerStats").hide()
	

func _process(delta):
	if Input.is_action_just_pressed("ui_stats"):
		_showPlayerStats()
	if Input.is_action_just_pressed("ui_cancel") and is_playing:
		_pause_game()
	elif Input.is_action_just_pressed("ui_cancel") and current_scene.NAME=="pausemenu" and not is_playing:
		_play_game()

func _showPlayerStats():
	var stats = get_node("./Map/GUI/PlayerStats")
	if stats.is_visible_in_tree():
		stats.hide()
	else:
		Server.FetchPlayerStats()
		stats.show()

func _play_game():
	#play game
	current_scene.queue_free()
	map.get_node("Room/Player").set_physics_process(true)
	map.get_node("Room/Player").set_process_input(true)
	map.get_node("Room/Player").set_process(true)	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	is_playing = true

func _pause_game():
	#pause game
	_change_scene("pausemenu")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	is_playing = false
	map.get_node("Room/Player").set_physics_process(false)
	map.get_node("Room/Player").set_process_input(false)
	map.get_node("Room/Player").set_process(false)	
	
func _change_scene(scene):
	if current_scene:
		scene_stack.append(current_scene.NAME)
		if scene_stack.size() > 1:
			scene_stack.pop_front()
			
		current_scene.exit(self)
	elif not is_playing :
		scene = "mainmenu"
	current_scene = scene_map[scene].instance()
	add_child(current_scene)
	current_scene.enter(self)
	
func _back():
	if scene_stack.size() > 0:
		var scene = scene_stack.pop_front()
		_change_scene(scene)

func _setting_reload():
	
	print("setting changed scenehandler")


func set_alert(text):
	# make a pop up with alert
	popbox.get_node("Label").set_text(text)
	popbox.popup()	
func _on_Button_pressed():
	#popbox close
	popbox.hide()

func set_info(text):
	#show info screen
	infoscreen.get_node("BackOverlay/Label").set_text(text)
	infoscreen.popup()

func dismiss_info():
	#hide info screen
	infoscreen.hide()
	
func _quit():
	if Gateway.CONNECTED:
		Gateway.network.close_connection()
	if Server.CONNECTED:
		Server.network.close_connection()
	get_tree().quit()
		
	
func play_background_sound():
	get_node("BackgroundSound").play()
	
func play_click_sound():
	get_node("ClickSound").play()
	get_node("ClickSound/TimerClick").start()

func _on_TimerClick_timeout():
	get_node("ClickSound").stop()

#login screen in client

extends Control

const NAME ="loginmenu"

onready var login_screen = get_node("Background/VBoxContainer")
onready var create_account_screen = get_node("Background/VBoxContainer2")


onready var username_input = get_node("Background/VBoxContainer/Username")
onready var userpassword_input = get_node("Background/VBoxContainer/Password")
onready var login_button = get_node("Background/VBoxContainer/LoginButton")
onready var create_account_button = get_node("Background/VBoxContainer/CreateAccountButton")

onready var create_username_input = get_node("Background/VBoxContainer2/Username")
onready var create_userpassword_input = get_node("Background/VBoxContainer2/Password")
onready var create_userpassword__repeat_input = get_node("Background/VBoxContainer2/RepeatPassword")
onready var confirm_button = get_node("Background/VBoxContainer2/ConfirmButton")
onready var back_button = get_node("Background/VBoxContainer2/BackButton")
onready var mainmenu_button = get_node("BackOverlay/VBoxContainer/MainMenuButton")
onready var setting_button = get_node("BackOverlay/VBoxContainer/SettingsButton")


var last_screen :int = 0

var parent_scene = null

func _ready():
	pass
	
func enter(host):
	parent_scene = host
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	show()


func exit(host):
	
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	queue_free()

	
func _on_LoginButton_pressed():
	
	#get_node("../../").SpawnPlayer()
	#get_node("../../").SpawnNewplayer(11111,Vector3(0,5,0))
	#queue_free()
	#return true
	# --------------------------------------------------------
	parent_scene.play_click_sound()
	if username_input.text == "" or userpassword_input.text =="":
		#popup and stop
		parent_scene.set_alert("Please provide valid user ID and password")
	else:
		disable_buttons()
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		parent_scene.set_info("Attempting to login...")
		#Server.ConnectToServer()
		Gateway.ConnectToServer(username ,password ,false)



func _on_CreateAccountButton_pressed():
	parent_scene.play_click_sound()
	login_screen.hide()
	create_account_screen.show()


func _on_BackButton_pressed():
	
	parent_scene.play_click_sound()
	if not last_screen:
		create_account_screen.hide()
		login_screen.show()
	else:
		create_account_screen.show()
		last_screen = 0


func _on_ConfirmButton_pressed():
	parent_scene.play_click_sound()
	if create_username_input.get_text() == "":
		parent_scene.set_alert("Please provide valide username")
	elif create_userpassword_input.get_text() == "":
		parent_scene.set_alert("Please provide valide password")
	elif create_userpassword__repeat_input.get_text() == "":
		parent_scene.set_alert("Please repeat your password")
	elif create_userpassword_input.get_text() != create_userpassword__repeat_input.get_text():
		parent_scene.set_alert("Password didn't match")
	elif create_userpassword_input.get_text().length() <=6 :
		parent_scene.set_alert("Password must contain at least 7 characters")
		
	else:
		disable_buttons()
		parent_scene.set_info("Creating account ...") 
		var username = create_username_input.get_text()
		var password = create_userpassword_input.get_text()
		Gateway.ConnectToServer(username ,password , true)


func _on_SettingsButton_pressed():
	parent_scene.play_click_sound()
	parent_scene._change_scene("settings")

func _on_MainMenuButton_pressed():
	parent_scene.play_click_sound()
	parent_scene._change_scene("mainmenu")
	
func disable_buttons():
	#disable buttons
	login_button.disabled = true
	create_account_button.disabled = true
	mainmenu_button.disabled = true
	back_button.disabled = true
	setting_button.disabled = true
	
func enable_buttons():
	#enable buttons
	login_button.disabled = false
	create_account_button.disabled = false
	mainmenu_button.disabled = false
	back_button.disabled = false
	setting_button.disabled = false

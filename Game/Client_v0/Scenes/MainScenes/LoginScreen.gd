#login screen in client

extends Control

onready var login_screen = get_node("Background/VBoxContainer")
onready var create_account_screen = get_node("Background/VBoxContainer2")
onready var settings_screen = get_node("Background/VBoxContainer3")

onready var username_input = get_node("Background/VBoxContainer/Username")
onready var userpassword_input = get_node("Background/VBoxContainer/Password")
onready var login_button = get_node("Background/VBoxContainer/LoginButton")
onready var create_account_button = get_node("Background/VBoxContainer/CreateAccountButton")

onready var create_username_input = get_node("Background/VBoxContainer2/Username")
onready var create_userpassword_input = get_node("Background/VBoxContainer2/Password")
onready var create_userpassword__repeat_input = get_node("Background/VBoxContainer2/RepeatPassword")
onready var confirm_button = get_node("Background/VBoxContainer2/ConfirmButton")
onready var back_button = get_node("Background/VBoxContainer2/BackButton")

onready var gateway_ip_input = get_node("Background/VBoxContainer3/GatewayIp")
onready var gateway_port_input = get_node("Background/VBoxContainer3/GatewayPort")
onready var settings_button = get_node("Background/SettingsButton")

var last_screen :int = 0

func _ready():
	print("login screen started")
	
func _on_LoginButton_pressed():
	
	#get_node("../../").SpawnPlayer()
	#get_node("../../").SpawnNewplayer(11111,Vector3(0,5,0))
	#queue_free()
	#return true
	# --------------------------------------------------------
	
	if username_input.text == "" or userpassword_input.text =="":
		#popup and stop
		print("Please provide valid userID and password")
	else:
		login_button.disabled = true
		create_account_button.disabled = true
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("attempting to login")
		#Server.ConnectToServer()
		Gateway.ConnectToServer(username ,password ,false)



func _on_CreateAccountButton_pressed():
	login_screen.hide()
	create_account_screen.show()


func _on_BackButton_pressed():
	settings_button.disabled = false
	settings_screen.hide()
	if not last_screen:
		create_account_screen.hide()
		login_screen.show()
	else:
		create_account_screen.show()
		last_screen = 0


func _on_ConfirmButton_pressed():
	if create_username_input.get_text() == "":
		print("Please provide valide username")
	elif create_userpassword_input.get_text() == "":
		print("Please provide valide password")
	elif create_userpassword__repeat_input.get_text() == "":
		print("Please repeat your password")
	elif create_userpassword_input.get_text() != create_userpassword__repeat_input.get_text():
		print("Password didn't match")
	elif create_userpassword_input.get_text().length() <=6 :
		print("Password must contain at least 7 characters")
		
	else:
		confirm_button.disabled = true
		back_button.disabled = true 
		var username = create_username_input.get_text()
		var password = create_userpassword_input.get_text()
		Gateway.ConnectToServer(username ,password , true)


func _on_SettingsButton_pressed():
	settings_button.disabled = true
	if login_screen.visible:
		last_screen = 0
		login_screen.hide()
	else:
		last_screen = 1
		create_account_screen.hide()
	gateway_ip_input.set_text(Gateway.ip)
	gateway_port_input.set_text(str(Gateway.port))
	settings_screen.show()
	
	


func _on_SaveButton_pressed():
	var gateway_ip = gateway_ip_input.get_text()
	var gateway_port = gateway_port_input.get_text()
	if gateway_ip.length() > 0 and gateway_port.length() > 0:
		Gateway.ip = gateway_ip
		Gateway.port = int(gateway_port)
		

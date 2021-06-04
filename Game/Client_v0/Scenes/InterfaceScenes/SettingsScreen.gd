extends Control

const NAME = "settings"

var default_gateway_ip = Settings.get_section("gateway")["ip"]
var default_server_ip = Settings.get_section("server")["ip"]
var default_gateway_port = Settings.get_section("gateway")["port"]
var default_server_port = Settings.get_section("server")["port"]

onready var server_ip_text = get_node("BackOverlay/VBoxContainer/TabContainer/Server/VBoxContainer/Ip/LineEdit")
onready var server_port_text = get_node("BackOverlay/VBoxContainer/TabContainer/Server/VBoxContainer/Port/LineEdit")

onready var gateway_ip_text = get_node("BackOverlay/VBoxContainer/TabContainer/Gateway/VBoxContainer2/Ip/LineEdit")
onready var gateway_port_text = get_node("BackOverlay/VBoxContainer/TabContainer/Gateway/VBoxContainer2/Port/LineEdit")

onready var parent_scene = null



func _ready():
	#load data to screen
	server_ip_text.set_text(default_server_ip)
	server_port_text.set_text(str(default_server_port))
	gateway_ip_text.set_text(default_gateway_ip)
	gateway_port_text.set_text(str(default_gateway_port))
	
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
	



func _on_Back_pressed():
	parent_scene.play_click_sound()
	parent_scene._back()


func _on_Save_pressed():
	parent_scene.play_click_sound()
	var server_ip = server_ip_text.get_text()
	var server_port = server_port_text.get_text()
	var gateway_ip = gateway_ip_text.get_text()
	var gateway_port = gateway_port_text.get_text()
	
	if server_ip !="":
		Settings.set_section("server","ip",server_ip)
	if server_port != "":
		Settings.set_section("server","port",int(server_port))
	if gateway_ip != "":
		Settings.set_section("gateway","ip",gateway_ip)
	if gateway_port !="":
		Settings.set_section("gateway","port",int(gateway_port))
	Settings.save_settings()
		
		
		

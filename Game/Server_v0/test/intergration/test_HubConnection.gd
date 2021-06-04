#connect to Authentication server to receive token

extends "res://addons/gut/test.gd"
#network  setup
var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1912
var client_port = 1909

onready var gameserver #get_node("/root/Server")

func _process(delta):
	#check whether custom multiplayer api is set
	if  get_custom_multiplayer() == null:
		return
	#check whether custom multiplayer network is set
	if not custom_multiplayer.has_network_peer():
		return
	#start custom_multiplayer poll
	custom_multiplayer.poll();

func before_each():
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.create_client(ip ,port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	#connect signals
	network.connect("connection_failed" ,self ,"_OnConnectionFailed")
	network.connect("connection_succeeded" ,self ,"_OnConnectionSucceeded")
func after_each():
	network = null
	set_custom_multiplayer(null)
	
	
func test_gamehub_connection():
	watch_signals(network)
	gut.p("-------------GameHub connection success----------")
	yield(yield_to(network,"connection_succeeded",2),YIELD)
	assert_signal_emitted(network ,"connection_succeeded")
	
func test_gamehub_connection_failed():
	watch_signals(network)
	
	gut.p("-------------GameHub connection success----------")
	yield(yield_to(network,"connection_failed",10),YIELD)
	assert_signal_emitted(network ,"connection_failed")
	
func _OnConnectionFailed():
	
	print("Failed to connect to game server hub")
	


func _OnConnectionSucceeded():
	print("Succesfully connected to game server hub")
	

remote func ReceiveLoginToken(token):
	gameserver.expected_tokens.append(token)

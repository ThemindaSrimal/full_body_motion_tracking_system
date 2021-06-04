#connect to Authentication server to receive token

extends Node
#network  setup
var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1912
var client_port = 1909

onready var gameserver = get_node("/root/Server")


func _ready():
	
	var arguments = {}
	
	for argument in OS.get_cmdline_args():
		
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			
			var key_value = argument.split("=")
			var arg_key = key_value[0].lstrip("--")
			
			if "authPort"==arg_key and key_value[1] != "":
				port = int(key_value[1])
			
			elif "clientPort"==arg_key and key_value[1] != "":
				client_port = int(key_value[1])
				
			elif "authIP"==arg_key and key_value[1] != "":
				ip = key_value[1]
			else:
				print("Use --clientPort=<port:int> to Client connecting port /nUse --authPort=<port:int> to AuthServer port --ip=<ip:str> for AuthServer IP")
				get_tree().quit(-1)
	
	ConnectToServer()

func _process(delta):
	#check whether custom multiplayer api is set
	if  get_custom_multiplayer() == null:
		return
	#check whether custom multiplayer network is set
	if not custom_multiplayer.has_network_peer():
		return
	#start custom_multiplayer poll
	custom_multiplayer.poll();

func ConnectToServer():
	network.create_client(ip ,port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	#connect signals
	network.connect("connection_failed" ,self ,"_OnConnectionFailed")
	network.connect("connection_succeeded" ,self ,"_OnConnectionSucceeded")

func _OnConnectionFailed():
	
	print("Failed to connect to game server hub")
	


func _OnConnectionSucceeded():
	print("Succesfully connected to game server hub")
	

remote func ReceiveLoginToken(token):
	gameserver.expected_tokens.append(token)

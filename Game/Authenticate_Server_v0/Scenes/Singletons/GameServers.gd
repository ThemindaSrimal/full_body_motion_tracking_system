#connection to game servers

extends Node
#setup connection
var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()

var port = 1912
var auth_port = 1911
var max_players = 100

var gameserverlist = {}

func _ready():
	var arguments = {}
	
	for argument in OS.get_cmdline_args():
		
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			
			var key_value = argument.split("=")
			var arg_key = key_value[0].lstrip("--")
			if "gamePort"==arg_key and key_value[1] != "":
				port = int(key_value[1])
			
			elif "authPort"==arg_key and key_value[1] != "":
				auth_port = int(key_value[1])
			else:
				print("Use --gamePort=<port:int> to GameServer port /nUse --authPort=<port:int> to GatewayServer port")
				get_tree().quit(-1)
			
	StartServer()

func _process(delta):
	#start polling for custom multiplayer network
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func StartServer():
	network.create_server(port , max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Gamehub Server start on port ",port)

	network.connect("peer_connected" ,self ,"_Peer_Connected")
	network.connect("peer_disconnected" ,self ,"_Peer_Disconnected")

func _Peer_Connected(gameserver_id):
	print("Gameserver "+str(gameserver_id) +" connected")
	gameserverlist["GameServer1"] = gameserver_id

func _Peer_Disconnected(gameserver_id):
	print("Gameserver "+str(gameserver_id)+ " disconnected")

func DistributeLoginToken(token ,gameserver):
	var gameserver_peer_id = gameserverlist[gameserver]
	rpc_id(gameserver_peer_id,"ReceiveLoginToken",token)

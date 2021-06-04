#connection to game servers

extends "res://addons/gut/test.gd"
#setup connection
var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()

var port = 1912
var auth_port = 1911
var max_players = 100

var gameserverlist = {}

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
	network.connect("peer_connected" ,self ,"_Peer_Connected")
	network.connect("peer_disconnected" ,self ,"_Peer_Disconnected")

func _Peer_Connected(gameserver_id):
	
	gameserverlist["GameServer1"] = gameserver_id

func _Peer_Disconnected(gameserver_id):
	pass

func DistributeLoginToken(token ,gameserver):
	pass

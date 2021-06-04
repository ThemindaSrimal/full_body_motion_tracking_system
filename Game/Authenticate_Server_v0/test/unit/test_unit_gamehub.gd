extends "res://addons/gut/test.gd"

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()

var port = 1912
var auth_port = 1911
var max_players = 100

var gameserverlist = {}
func after_all():
	network.close_connection(100)

func _ready():
	set_process(false)
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
	set_process(true)
	
func test_dummy_gamehubserver():
	gut.p("------run gamehub server 20s-----------")
	StartServer()
	watch_signals(network)
	yield(yield_to(network,"peer_connected",20),YIELD)
	

func _Peer_Connected(gameserver_id):
	
	pass

func _Peer_Disconnected(gameserver_id):
	pass
 

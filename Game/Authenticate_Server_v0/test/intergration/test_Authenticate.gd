#authenticate server test 

extends "res://addons/gut/test.gd"
var gameserver_script = load("res://test/intergration/test_GameServers.gd")
var TestGameServers
var TestClientGateway

var network = NetworkedMultiplayerENet.new()
var max_players = 5

func before_all():
	TestGameServers = autofree(double(gameserver_script).new())
	
	network.create_server(TestGameServers.auth_port, max_players)
	get_tree().set_network_peer(network)
	network.connect("peer_connected" , self ,"_Peer_Connected")
	network.connect("peer_disconnected" ,self ,"_Peer_Disconnected")
	
func after_all():
	pass

func test_Peer_Connected():
	watch_signals(network)
	yield(yield_to(self,"peer_connected",5),YIELD)
	gut.p("----------------test gateway connection--------------------")
	assert_signal_emitted(network,"peer_connected")
	
func test_Peer_Disconnected():
	watch_signals(network)
	yield(yield_to(self,"peer_connected",5),YIELD)
	gut.p("----------------test gateway disconnection--------------------")	
	assert_signal_emitted(network,"peer_disconnected")
	

func _Peer_Connected(_gateway_id):
	pass

func _Peer_Disconnected(_gateway_id):
	pass

remote func AuthenticatePlayer(username ,password ,player_id):
	pass

remote func CreateAccount(username ,password, player_id):
	pass

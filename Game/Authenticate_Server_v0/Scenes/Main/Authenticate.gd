#authenticate server

extends Node

var network = NetworkedMultiplayerENet.new()
var max_players = 5

func _ready():
	
	StartServer()

func StartServer():
	network.create_server(GameServers.auth_port, max_players)
	get_tree().set_network_peer(network)
	print("Authentication Server start on port ",GameServers.auth_port)

	network.connect("peer_connected" , self ,"_Peer_Connected")
	network.connect("peer_disconnected" ,self ,"_Peer_Disconnected")

func _Peer_Connected(gateway_id):
	print("Gateway " + str(gateway_id) + " is connected")

func _Peer_Disconnected(gateway_id):
	print("Gateway "+ str(gateway_id) + " is disconnected")

remote func AuthenticatePlayer(username ,password ,player_id):
	var token
	print("authentication request received")
	#get player id
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	print("Starting Authentication")
	#authorization 
	if not PlayerData.PlayerIDs.has(username):
		print("User not recognized")
		result = false
	elif not PlayerData.PlayerIDs[username].Password == password:
		print("Increase password")
		result  =false
	else:
		print("Succesful authentication")
		result = true

		randomize()
		token = str(randi()).sha256_text() + str(OS.get_unix_time())
		var gameServer = "GameServer1"
		GameServers.DistributeLoginToken(token, gameServer)
	#send result
	print("authentication result send to gateway server")
	rpc_id(gateway_id ,"AuthenticateResults" ,result ,player_id ,token)

remote func CreateAccount(username ,password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	if PlayerData.PlayerIDs.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		PlayerData.PlayerIDs[username] = {"Password":password}
		PlayerData.SavePlayerIDs()
		
	rpc_id(gateway_id ,"CreateAccountResults", result ,player_id ,message)

#create a Node named server
extends Node

const TOKEN_VALID_TIME = 50
var network = NetworkedMultiplayerENet.new()
var max_players = 100 

onready var player_verification_process = get_node("PlayerVerification")
onready var server_room = get_node("ServerRoom")
onready var combat_function = get_node("Combat")
#store expecting token from client
var expected_tokens = []
#collect all player states
var player_state_collection ={}


func _ready():
	StartServer()

func StartServer():
	network.create_server(HubConnection.client_port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")

	network.connect("peer_connected" , self ,"_Peer_Connected")
	network.connect("peer_disconnected" ,self ,"_Peer_Disconnected")

func _Peer_Connected(player_id):
	print("User " + str(player_id) + " is connected")
	#start player verification node
	player_verification_process.start(player_id)

func _Peer_Disconnected(player_id):
	print("User "+ str(player_id) + " is disconnected")
	if has_node(str(player_id)):
		#remove player
		get_node(str(player_id)).queue_free()
		#remove player state
		player_state_collection.erase(player_id)
		rpc_id(0, "DespawnPlayer",player_id)

#--------------server functions-------------

func _on_TokenExpiration_timeout():
	#check token time every 10s
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1 ,-1,-1):
			token_time = int(expected_tokens[i].right(64))
			#remove token generated time is more than TOKEN_VALID_TIME
			if current_time - token_time >= TOKEN_VALID_TIME:
				expected_tokens.remove(i)
	print("Expected Token:")
	print(expected_tokens)

func FetchToken(player_id):
	#tell client to send token
	rpc_id(player_id ,"FetchToken")

remote func ReturnToken(token):
	#verify received token from client
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.Verify(player_id ,token)

func ReturnTokenVerificationResults(player_id ,result):
	#send verification result ot client
	rpc_id(player_id ,"ReturnTokenVerificationResults" ,result)
	if result==true:
		var new_pos = server_room.SpawnPlayers()
		rpc_id(0,"SpawnNewPlayer" ,player_id ,new_pos)

remote func FetchSkillDamage(skill_name, requester):
	print("ask for damage data")
	#get requested peer id :inside player scene  
	var player_id  = get_tree().get_rpc_sender_id()
	# add to autoload and call combat.FtechSkillDamage(skill_name)
	var damage = combat_function.FetchSkillDamage(skill_name ,player_id)
	rpc_id(player_id ,"ReturnSkillDamage" ,damage ,requester)
	print("sending "+str(damage) + "to player")

remote func FetchPlayerStats():
	var player_id = get_tree().get_rpc_sender_id()
	var player_stats = get_node(str(player_id)).player_stats	
	rpc_id(player_id,"ReturnPlayerStats",player_stats)
	
remote func ReceivePlayerState(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		#check player id exists
		if player_state_collection[player_id]["T"] < player_state["T"]:
			#get only latest player state and save it
			player_state_collection[player_id] = player_state 
	else:
		#add new player id state to collection
		player_state_collection[player_id] = player_state
		
func SendWorldState(world_state):
	#send world state to player
	rpc_unreliable_id(0 ,"ReceiveWorldState" ,world_state)
	
remote func FetchServerTime(client_time):
	#send server and client time to client
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id ,"ReturnServerTime" ,OS.get_system_time_msecs() ,client_time)
	
remote func DetermineLatency(client_time):
	#reply to client to calculate latency
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnLatency" ,client_time)
	

remote func Attack(attacker_pos,hit_enemies,attack_time):
	print("Attack received")
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(0,"ReceiveAttack",attacker_pos,hit_enemies,attack_time,player_id)
	
	
remote func Dead():
	#change player position
	var player_id = get_tree().get_rpc_sender_id()
	print(str(player_id), " dead")
	if has_node(str(player_id)):
		#get new position
		var new_pos = server_room.SpawnPlayers()
		#respawn player
		rpc_id(0,"ReSpawnPlayer" ,player_id ,new_pos)
	
	

#client side server
extends Node

var network = NetworkedMultiplayerENet.new()
var ip = Settings.get_section("server")["ip"]
var port = Settings.get_section("server")["port"]
var CONNECTED = false

#------------clock variables--------------------
var decimal_collector :float = 0
var latency = 0
var latency_array = []
var delta_latency = 0
var client_clock = 0
# -------------------------------------------
var token

var scene_handler = null

func _ready():
	#ConnectToServer()
	pass

func _load_settings():
	print("server setting chnaged")
	ip = Settings.get_section("server")["ip"]
	port = Settings.get_section("server")["port"]
	
func _physics_process(delta): 
	#delat in msecs convert to secs
	client_clock += int(delta * 1000) + delta_latency
	delta_latency =0
	# decimal after convert delta into integer
	decimal_collector += (delta *1000) - int(delta *1000)
	if decimal_collector >= 1.00:
		client_clock +=1
		decimal_collector -= 1.00

func ConnectToServer():
	if not scene_handler:
		#set up scene handler
		scene_handler = get_node("../SceneHandler")
	ip = Settings.get_section("server")["ip"]
	port = Settings.get_section("server")["port"]
	
	network.create_client(ip ,port)
	get_tree().set_network_peer(network)
	
	#connect signals 
	connect_signals()

func ReConnectToServer():
	var attempts = 0
	while not CONNECTED:
		if attempts > 2:
			scene_handler.dismiss_info()
			scene_handler.set_alert("Connection failed!")
			break
		ConnectToServer()
		print("trying to connect")
		yield(get_tree().create_timer(2),"timeout")
		attempts += 1
		
	
func _OnConnectionFailed():
	scene_handler.dismiss_info()
	scene_handler.set_alert("Failed to connect to the server.\nPlease ,try again.")
	get_node("../SceneHandler/LoginScreen").enable_buttons()
	disconnect_signals()
	network.close_connection()
	CONNECTED = false
	

func _OnConnectionSucceeded():
	
	scene_handler.dismiss_info()
	print("Succesfully connected")
	CONNECTED = true
	# start clock sync
	rpc_id(1 ,"FetchServerTime" ,OS.get_system_time_msecs())
	#latency adjusment
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout" ,self ,"DetermineLatency")
	self.add_child(timer)
	
func _OnServerDisconnected():
	
	CONNECTED = false
	scene_handler.map.set_physics_process(false)
	scene_handler._pause_game()
	scene_handler.set_info("Server disconnected!\nRetry connecting...")
	disconnect_signals()
	ReConnectToServer()
	


func connect_signals():
	#connect signal to network
	network.connect("connection_failed" ,self ,"_OnConnectionFailed")
	network.connect("connection_succeeded" ,self ,"_OnConnectionSucceeded")
	network.connect("server_disconnected", self ,"_OnServerDisconnected")

func disconnect_signals():
	#disconnect signals from network
	network.disconnect("connection_failed" ,self ,"_OnConnectionFailed")
	network.disconnect("connection_succeeded" ,self ,"_OnConnectionSucceeded")
	network.disconnect("server_disconnected", self ,"_OnServerDisconnected")

remote func ReturnServerTime(server_time ,client_time):
	latency = (OS.get_system_time_msecs() - client_time ) /2
	client_clock = server_time + latency 
	
func DetermineLatency():
	if CONNECTED:
		rpc_id(1 ,"DetermineLatency" , OS.get_system_time_msecs())
	
remote func ReturnLatency(client_time):
	latency_array.append(( OS.get_system_time_msecs() -client_time ) /2)
	# collect 9 latency values
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		#to remove extreme value cause by packet loss get mid point 
		var mid_point = latency_array[4]
		for i in range(latency_array.size() -1 ,-1,-1):
			if latency_array[i] > ( 2* mid_point) and latency_array[i] > 20:
				#remove that values
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		
		delta_latency = (total_latency / latency_array.size()) - latency 
		latency = total_latency / latency_array.size()
		#print("New latency ",latency)
		#print("Delta latency" ,delta_latency)
		latency_array.clear()
		
				
			
	
remote func FetchToken():
	rpc_id(1,"ReturnToken" ,token)

remote func ReturnTokenVerificationResults(result):
	if result == true :
		print("Successful token verfication")
		scene_handler._play_game()
	else:
		scene_handler.dismiss_info()
		scene_handler.set_alert("Login failed , please try again")
		get_node("../SceneHandler/LoginScreen").enable_buttons()
#-------------------------------------
func FetchSkillDamage(skill_name ,requester):
	if CONNECTED:
		#call the server
		rpc_id(1 , "FetchSkillDamage" ,skill_name ,requester)
func SendAttack(attack_position,firearm):
	#send player attack to server
	rpc_id(1,"Attack",attack_position,firearm,client_clock)
	
	
remote func ReceiveAttack(attacker_pos,hit_enemy,attack_time,attacker):
	if attacker==get_tree().get_network_unique_id():
		#player made the shoot
		pass
	else:
		get_node("/root/SceneHandler/Map/Room/OtherPlayers/"+str(attacker)).attack_dict[attack_time]={"position":attacker_pos,"hit_enemy":hit_enemy}
		
func SendDied():
	rpc_id(1,"Dead")
	
remote func ReturnSkillDamage(s_damage, requester):
	#assign data to node
	instance_from_id(requester).SetDamage(s_damage)
	
func FetchPlayerStats():
	if CONNECTED:
		rpc_id(1,"FetchPlayerStats")

remote func ReturnPlayerStats(stats):
	get_node("/root/SceneHandler/Map/GUI/PlayerStats").LoadPlayerStats(stats)
	
	
remote func SpawnNewPlayer(player_id ,spawn_position):
	#server send new player spawn position
	get_node("../SceneHandler/Map").SpawnNewPlayer(player_id ,spawn_position)

remote func DespawnPlayer(player_id):
	#remove player
	get_node("../SceneHandler/Map").DespawnPlayer(player_id )
	
remote func ReSpawnPlayer(player_id,spawn_position):
	get_node("../SceneHandler/Map").ReSpawnPlayer(player_id ,spawn_position)
	
func SendPlayerState(player_state):
	#send player state to server
	if CONNECTED:
		
		rpc_unreliable_id(1 ,"ReceivePlayerState",player_state)
	
remote func ReceiveWorldState(world_state):
	get_node("../SceneHandler/Map").UpdateWorldState(world_state)
	


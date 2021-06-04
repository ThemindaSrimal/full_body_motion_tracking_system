#verify player
extends Node

onready var main_interface = get_parent()
onready var player_container_scene = preload("res://../Scenes/Instances/PlayerContainer.tscn")

var awaiting_verification = {}

func start (player_id):
	#set client token receive time
	awaiting_verification[player_id] = {"Timestamp":OS.get_unix_time()}
	main_interface.FetchToken(player_id)
	


func Verify(player_id ,token):
	#verify player
	var token_verification = false
	while OS.get_unix_time() - int(token.right(64)) <= main_interface.TOKEN_VALID_TIME:
		if main_interface.expected_tokens.has(token):
			token_verification = true
			createPlayerContainer(player_id ,token)
			awaiting_verification.erase(player_id)
			main_interface.expected_tokens.erase(token)
			break
		else:
			#wait
			yield(get_tree().create_timer(2),"timeout")
	main_interface.ReturnTokenVerificationResults(player_id, token_verification)
	if token_verification == false:
		#remove if token not received
		awaiting_verification.erase(player_id)
		main_interface.network.disconnect_peer(player_id)

func _on_VerificationExpiration_timeout():
	var current_time = OS.get_unix_time()
	var start_time
	if awaiting_verification == {}:
		pass
	else:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].Timestamp
			if current_time - start_time >= main_interface.TOKEN_VALID_TIME:
				awaiting_verification.erase(key)
				var connected_peers = Array(get_tree().get_network_connected_peers())
				if connected_peers.has(key):
					main_interface.ReturnTokenVerificationResults(key ,false)
					main_interface.network.disconnect_peer(key)
	print("Awaiting verification")
	print(awaiting_verification)



func createPlayerContainer(player_id ,token):
	#make player container instance
	var new_player_container = player_container_scene.instance()
	#change container name to player id
	new_player_container.name = str(player_id)
	#add player token to container
	new_player_container.player_token = token
	#add player container
	get_parent().add_child(new_player_container ,true)
	var player_container = get_node("../"+str(player_id))
	#fill player data
	FillPlayerContainer(player_container)

func FillPlayerContainer(player_container):
	#reteive data from server
	player_container.player_stats = ServerData.test_data.Stats

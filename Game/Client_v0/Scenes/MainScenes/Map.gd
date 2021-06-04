extends Node2D

var player_template = preload("res://Scenes/SupportScenes/PlayerTemplate.tscn")
var player_scene = preload("res://Scenes/SupportScenes/Player.tscn")

var last_world_state = 0
var world_state_buffer =[]
const interpolation_offset = 100



onready var parent_scene = null

func SpawnNewPlayer(player_id ,spawn_position):
	# spawn and respawn happend here
	if not (spawn_position[0] is Vector3):
		return false
	print(spawn_position)
	
	if get_tree().get_network_unique_id() == player_id:
		#this is the current player 
		$Room/Player.global_transform.origin = spawn_position[0]
		$Room/Player.rotation_degrees = spawn_position[1]
		$Room/Player.Health = 100
		yield(get_tree().create_timer(1),"timeout")
		get_node("../").dismiss_info()
	else:
		if not get_node("Room/OtherPlayers").has_node(str(player_id)):
			var new_player = player_template.instance()
			new_player.name = str(player_id)
			#add group name for ray cast detection
			new_player.add_to_group("Enemy")
			get_node("Room/OtherPlayers").add_child(new_player)
			new_player.global_transform.origin = spawn_position[0]
			new_player.rotation_degrees= spawn_position[1]
			new_player.Health = 100
func DespawnPlayer(player_id):
	#wait 200ms unitl world state clear to remove player
	yield(get_tree().create_timer(0.2),"timeout")
	if get_node("Room/OtherPlayers").has_node(str(player_id)):
		get_node("Room/OtherPlayers/"+str(player_id)).queue_free()
	
func UpdateWorldState(world_state):
	
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
		
func _physics_process(delta):
	# [ extra past state , past state , inter future state , future state ]
	var render_time = Server.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			#keep nearest future state
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					#consider players in both world states
					continue
				if get_node("Room/OtherPlayers").has_node(str(player)):
					#var new_position = lerp(world_state_buffer[1][player]["P"].origin ,world_state_buffer[2][player]["P"].origin, interpolation_factor)
					var new_position = world_state_buffer[2][player]["P"].origin.linear_interpolate(world_state_buffer[1][player]["P"].origin,interpolation_factor)
					var new_rotation = Quat(world_state_buffer[1][player]["P"].basis).slerp(world_state_buffer[2][player]["P"].basis,interpolation_factor)
					get_node("Room/OtherPlayers/" + str(player)).MovePlayer(new_position,new_rotation)
					get_node("Room/OtherPlayers/" + str(player)).AnimatePlayer(world_state_buffer[1][player]["A"])
				else:
					#spawn player
					SpawnNewPlayer(player,world_state_buffer[2][player]["P"])
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float( render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"] - 1.00)
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					#consider players in both world states
					continue
				if get_node("Room/OtherPlayers").has_node(str(player)):
					var position_delta = ( world_state_buffer[1][player]["P"].origin - world_state_buffer[0][player]["P"].origin)
					var new_position = world_state_buffer[1][player]["P"].origin +( position_delta * extrapolation_factor)
					var new_rotation = Quat(world_state_buffer[0][player]["P"].basis).slerp(world_state_buffer[1][player]["P"].basis,extrapolation_factor)
					get_node("Room/OtherPlayers/" + str(player)).MovePlayer(new_position,new_rotation)
					

func ReSpawnPlayer(player_id ,spawn_position):
	# spawn and respawn happend here
	if not (spawn_position[0] is Vector3):
		return false
	print(spawn_position)
	
	if get_tree().get_network_unique_id() == player_id:
		#this is the current player 
		#update position
		$Room/Player.global_transform.origin = spawn_position[0]
		$Room/Player.rotation_degrees = spawn_position[1]
		#update data
		$Room/Player.UpdateData()
		get_node("../").dismiss_info()
	else:
		if get_node("Room/OtherPlayers").has_node(str(player_id)):
			
			var new_player = get_node("Room/OtherPlayers/"+str(player_id))
			#update position
			new_player.global_transform.origin = spawn_position[0]
			new_player.rotation_degrees= spawn_position[1]
			#update data
			new_player.UpdateData()
			yield(get_tree().create_timer(2),"timeout")
			new_player.show()
func SpawnPlayer():
	var player = player_scene.instance()
	player.name="Player"
	get_node("Room").add_child(player)
	

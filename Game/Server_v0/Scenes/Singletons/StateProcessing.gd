extends Node


var world_state = {}

func _physics_process(delta):
	#run 20 per secs
	if not get_parent().player_state_collection.empty():
		#create a snapshot of player state collection
		world_state = get_parent().player_state_collection.duplicate(true)
		for player in world_state.keys():
			#remove timestamp
			world_state[player].erase("T")
		#make new timestamp
		world_state["T"] = OS.get_system_time_msecs()
		get_parent().SendWorldState(world_state)

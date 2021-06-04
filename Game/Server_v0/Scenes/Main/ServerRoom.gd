extends Spatial


var player_spawn_points=[[Vector3(0,4.226,-43.98),Vector3(0,180,0)],[Vector3(0,4.226,41.978),Vector3(0,0,0)]]

var open_location=[0,1]
var occupied_locations ={}


func _ready():
	
	var timer = Timer.new()
	timer.wait_time = 3
	timer.autostart = true
	
func SpawnPlayers():
	randomize()
	var player_location_index = randi()%open_location.size()
	var location = player_spawn_points[open_location[player_location_index]]
	
	return location
	

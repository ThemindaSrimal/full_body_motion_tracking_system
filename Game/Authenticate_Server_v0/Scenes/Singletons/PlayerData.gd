#load player data

extends Node

var PlayerIDs
var PLAYEERIDS_PATH = "user://playerIds.json"

func _ready():
	
	var directory = Directory.new()
	var PlayerIds_data_file = File.new()
	if directory.file_exists(PLAYEERIDS_PATH):
		PlayerIds_data_file.open(PLAYEERIDS_PATH ,File.READ)
		var PlayerIds_data_json = JSON.parse(PlayerIds_data_file.get_as_text())
		PlayerIds_data_file.close()
		PlayerIDs = PlayerIds_data_json.result
	else:
		
		PlayerIDs = {}
		


func SavePlayerIDs():
	var save_file = File.new()
	save_file.open(PLAYEERIDS_PATH ,File.WRITE)
	save_file.store_line(to_json(PlayerIDs))
	save_file.close()

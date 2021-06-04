#server side player data handle

extends Node

var skill_data
var test_data ={
	"Stats":{
		"Strenght": 42,
		"Vitality":68
	}
}

func _ready():
	var skill_data_file = File.new()
	skill_data_file.open("res://Data/DataSheet.json" ,File.READ)
	var skill_data_json = JSON.parse(skill_data_file.get_as_text())
	skill_data_file.close()
	skill_data = skill_data_json.result


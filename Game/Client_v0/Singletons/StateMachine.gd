extends Node

#hold application states
enum states { 
	INIT,
	LOGIN,
	}

var _is_gateway_connected = false
var _is_server_connected = false
var _is_logged_in = false


var current_state = null

func _ready():
	pass


func _change_state(state):
	
	pass

	

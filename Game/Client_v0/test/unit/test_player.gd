extends "res://addons/gut/test.gd"

var Player = load("res://Scenes/SupportScenes/Player.gd")

class StubNode:
	extends Node
	var ev
	
	func _ready():
		ev = InputEventKey.new()
		ev.set_scancode(KEY_SPACE)
		
	func _process(delta):
		_input(ev)
		
func keypress(key):
	var ev = InputEventKey.new()
	ev.set_scancode(key)
	return ev

func test_can_create_player():
	var p = autofree(Player.new())
	assert_not_null(p)
	
func test_player_no_key_press():
	var p = autofree(double(Player,DOUBLE_STRATEGY.FULL).new())
	stub(p,"_physics_process").to_call_super()
	simulate(p,1,1)
	assert_eq(p.direction ,Vector3.ZERO)
	assert_almost_eq(p.fall.y, -9.8 ,.5,"fall.y ~= -9.8 ")



extends Node

export var damage = 10
var get_damage = false

func _ready():
	pass

func _process(delta):
	if Server.CONNECTED && !get_damage:
		#fetch gun damage from server
		Server.FetchSkillDamage("Pistol" , get_instance_id())
		get_damage = true
		
	
func SetDamage(s_damage):
	print(s_damage)

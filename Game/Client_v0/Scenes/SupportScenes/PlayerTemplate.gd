extends KinematicBody

#{"position":attacker_pos,"hit_enemy":hit_enemy}
var attack_dict ={}

var Health = 100

func _physics_process(delta):
	if not attack_dict.empty():
		Attack()

func MovePlayer(new_position,new_rotation):
	
	 set_transform(Transform(new_rotation ,new_position))

func AnimatePlayer(animation_name):
	
	if animation_name=="idle":
		$soldier/AnimationPlayer.play("fire Retarget")
		
	elif animation_name=="walk":
		$soldier/AnimationPlayer.play("walk Retarget")
		
		
	if animation_name=="jump":
		$soldier/AnimationPlayer.play("jump Retarget")
		

func Attack():
	for attack in attack_dict.keys():
		#time is ok attack
		if attack <= Server.client_clock:
			if attack_dict[attack]["hit_enemy"]==str(get_tree().get_network_unique_id()):
				get_node("../../Player").Damage()
			else:
				get_node("../"+attack_dict[attack]["hit_enemy"]).Damage()
		attack_dict.erase(attack)
				

func Damage():
	Health-=20
	if Health <= 0:
		hide()
	
func UpdateData():
	Health = 100

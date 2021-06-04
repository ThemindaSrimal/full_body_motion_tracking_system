extends KinematicBody

onready var head := $Head
onready var hand := $Head/Hand
onready var handloc := $Head/HandLoc
onready var aimcast := $Head/Camera/AimCast
onready var weapon := $Head/Hand/Weapon
onready var player_info:= $Head/Camera/PlayerInfo
onready var b_cal := preload("res://Scenes/TestScenes/BulletDecals.tscn")

const SWAY = 30

export var SPEED = 7
export var ACCELERATION = 20
export var GRAVITY = 9.8
export var JUMP = 5

#player health
var Health =100
var MOUSE_SENSIVITY = 0.05

var direction := Vector3()
var velocity := Vector3()
var fall := Vector3()

#player state
var player_state
#hold the animation detail
var current_animation

var hit_targets =""

func _ready():
	#set physics process off
	set_physics_process(false)
	#lock and hide cursor
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hand.set_as_toplevel(true)
	#player_info.get_node("HP").set_text("HP: %s"%(str(Health)))
	player_info.get_node("HPBar").value = Health
	 

func _input(event):
	
	if (event is InputEventMouseMotion ) and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x*MOUSE_SENSIVITY))
		head.rotate_x(deg2rad(-event.relative.y*MOUSE_SENSIVITY))
		head.rotation.x = clamp(head.rotation.x ,deg2rad(-90),deg2rad(90))
		current_animation = "fire"
		
func _process(delta):
	
	hand.global_transform.origin = handloc.global_transform.origin
	hand.rotation.y = lerp_angle(hand.rotation.y ,rotation.y ,SWAY *delta)
	hand.rotation.x = lerp_angle(hand.rotation.x ,head.rotation.x ,SWAY *delta)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#set default animation
	current_animation="idle"
	
	fire()
	direction = Vector3()
		
	if not is_on_floor():
		fall.y -= GRAVITY * delta
		current_animation= "jump"
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		fall.y = JUMP
		current_animation="jump"
	
	if Input.is_action_pressed("movement_forward"):
		direction -= transform.basis.z
		current_animation="walk"
	elif  Input.is_action_pressed("movement_backword"):
		direction += transform.basis.z
		current_animation="walk"
	if Input.is_action_pressed("movement_left"):
		direction -= transform.basis.x
		current_animation="walk"
	elif Input.is_action_pressed("movement_right"):
		direction += transform.basis.x
		current_animation="walk"
	
	direction = direction.normalized()
	
	velocity = velocity.linear_interpolate(direction * SPEED ,ACCELERATION *delta)
	velocity = move_and_slide(velocity ,Vector3.UP)
	move_and_slide(fall ,Vector3.UP)
	
	DefinePlayerState()
	
	
func fire():
	#fire weapon
	if Input.is_action_pressed("fire") and weapon.cooldown_timer.is_stopped():
		#check weapon is cooldowned 
		#get hited objects
		if aimcast.is_colliding():
			var target = aimcast.get_collider()
			if target.is_in_group("Walls"):
				var b = b_cal.instance()
				target.add_child(b)
				b.global_transform.origin = aimcast.get_collision_point()
				b.look_at(aimcast.get_collision_point() + aimcast.get_collision_normal(), Vector3.UP)
			elif target.is_in_group("Enemy"):
				hit_targets = target.name
		if weapon.shoot():
			if hit_targets != "":
				#print("hit target ",hit_targets)
				#send attack if player hit enemy
				Server.SendAttack(global_transform,hit_targets)
			player_info.get_node("Ammo").set_text("Ammo:%s"%(str(weapon.bullets)))
			weapon.cooldown_timer.start()
			hit_targets = ""
		else:
			weapon.Reload()
	else:
		pass
		
		
func DefinePlayerState():
	#make player state
	player_state = {"T":Server.client_clock ,"P":get_global_transform().orthonormalized(),"A":current_animation}
	Server.SendPlayerState(player_state)
	

func Damage():
	
	Health -=20
	#print(Health)
	#player_info.get_node("HP").set_text("HP: %s"%(str(Health)))
	player_info.get_node("HPBar").value = Health
	if Health <= 0:
		#print("died")
		Server.SendDied()
		get_node("../../../").set_info("Dead!!")
		yield(get_tree().create_timer(5),"timeout")

func _on_ReloadTimer_timeout():
	weapon.bullets = weapon.MAGAZINE
	player_info.get_node("Ammo").set_text("Ammo:%s"%(str(weapon.bullets)))
	
func UpdateData():
	#update data in respawn
	Health=100
	weapon.bullets = weapon.MAGAZINE
	player_info.get_node("Ammo").set_text("Ammo:%s"%(str(weapon.bullets)))
	#player_info.get_node("HP").set_text("HP: %s"%(str(Health)))
	player_info.get_node("HPBar").value = Health


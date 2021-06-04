extends KinematicBody2D

# Called when the node enters the scene tree for the first time.
const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export var ACCELERATION = 400
export var MAX_SPEED = 150
export var FRICTION = 600
export var ROLL_SPEED = 170
export(bool) var shooting_while_walking = true

enum {
	MOVE,	#0	auto assigned
	ROLL,	#1
	ATTACK	#2
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats #global autoload singleton

#shoot
var spell = preload("res://Shoot/Spell.tscn")
var can_fire = true
export(float) var rate_of_fire = 0.4

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/swardHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	#stats.connect("no_health",self,"queue_free()")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	
	
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()	
	
	
# warning-ignore:unused_argument
func _process(delta):
	SkillLoop()


func SkillLoop():
	if Input.is_action_pressed("Shoot") and can_fire == true:
		can_fire = false
		if shooting_while_walking == false:
			velocity = Vector2.ZERO
		get_node("TurnAxis").rotation = get_angle_to(get_global_mouse_position())
		var spell_instance = spell.instance()
		spell_instance.position = get_node("TurnAxis/CastPoint").get_global_position()
		spell_instance.rotation = get_angle_to(get_global_mouse_position())
		get_parent().add_child(spell_instance)
		yield(get_tree().create_timer(rate_of_fire),"timeout")
		can_fire = true
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	#print(input_vector)
	
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/idle/blend_position",input_vector)
		animationTree.set("parameters/Run/blend_position",input_vector)
		animationTree.set("parameters/Attack/blend_position",input_vector)
		animationTree.set("parameters/Roll/blend_position",input_vector)
		animationState.travel("Run")
		
		velocity= velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	
	else:
		animationState.travel("idle")
		velocity= velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	#print(velocity)
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("roll"):
		print("roll pressed")
		state = ROLL

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)


func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_animation_finished():
	state = MOVE

func roll_animation_finished():
	velocity = velocity * 0.8
	print("roll anim finished")
	state = MOVE


func _on_Hurtbox_area_entered(area):
	print("player hurtbox area entered signal passed")
	stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var playHurtSounds = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playHurtSounds)
	print(stats.health)
	if stats.health <= 0:
		queue_free()
	


func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")
	
func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

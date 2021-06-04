extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum{
	IDLE,
	WONDER,
	CHASE
}

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 3

export(int) var max_hp = 400
var current_hp 

var state = IDLE

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var playerDetectionZone = $PlayerDetectionZone
onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _ready():
	randomize() #make sure game always start with random seed comment this when debugging
	state = pick_random_state([IDLE,WONDER])
	current_hp = max_hp
	print(stats.max_health)
	print(stats.health)

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO,100*delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO,100*delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
					
		WONDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			
			accelerate_toward_point(wanderController.target_position, delta)
			
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE :
				update_wander()
				
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_toward_point(player.global_position, delta)
			else:
				state = IDLE
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_toward_point(point, delta):
		var direction = global_position.direction_to(point)
		velocity = velocity.move_toward(direction * MAX_SPEED,ACCELERATION*delta)
		sprite.flip_h = velocity.x < 0

func update_wander(): 
	state = pick_random_state([IDLE,WONDER])
	wanderController.start_wander_timer(rand_range(1,3))
				
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage	
	knockback = area.knockback_vector * 120
	#hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_Stats_no_health():
	BatDied()


func _on_Hurtbox_invincibility_started():
	animationPlayer.play("start")


func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
	
	
func OnHitBullets(damage):
	current_hp -= damage
	if current_hp <= 0:
		BatDied()
			
		
func BatDied():
	#get_node("CollisionShape2D").set_deffered("disabled",true) #if death body still there
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position 

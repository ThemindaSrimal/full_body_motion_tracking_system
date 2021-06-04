extends RigidBody2D

export(int) var projectile_speed = 500
export(float) var bullet_life_time = 3
export(int) var damage = 100

func _ready():
	#apply speed according to mouse rotation
	apply_impulse(Vector2(),Vector2(projectile_speed,0).rotated(rotation))
	SelfDestruct()
	
func SelfDestruct():
	yield(get_tree().create_timer(bullet_life_time),"timeout")
	queue_free()


# warning-ignore:unused_argument
func _on_Spell_body_entered(body):
	get_node("CollisionPolygon2D").set_deferred("disabled",true) #set deferred wait until other process finished
	if body.is_in_group("Enemies"):
		body.OnHitBullets(damage)
		self.hide()
	
	
	#elif body.is_in_group("walls"):pass
	#else:
	#	self.hide()
	

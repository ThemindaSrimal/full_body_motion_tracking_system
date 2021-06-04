extends MeshInstance

export var damage = 10
const MAGAZINE = 6
var bullets = MAGAZINE
var get_damage = false

var _is_reloading = false

onready var cooldown_timer = $CooldownTimer

func _ready():
	pass

func _process(delta):
	if Server.CONNECTED && !get_damage:
		#fetch gun damage from server
		Server.FetchSkillDamage("Pistol" , get_instance_id())
		get_damage = true
		
	
func SetDamage(s_damage):
	damage=s_damage
	
func shoot():
	if bullets> 0:
		play_sound("Shoot")
		$AnimationPlayer.play("Shoot")
		bullets-=1
		return true
	else:
		return false
		
func Reload():
	if not _is_reloading:
		_is_reloading = true
		play_sound("Reload")
		$ReloadTimer.start()
		$AnimationPlayer.play("Reload")


func play_sound(sound):
	if $Sounds.has_node(sound):
		$Sounds.get_node(sound).play()

func stop_sound(sound):
	if $Sounds.has_node(sound):
		$Sounds.get_node(sound).stop()

func _on_CooldownTimer_timeout():
	stop_sound("Shoot")


func _on_ReloadTimer_timeout():
	stop_sound("Reload")
	_is_reloading = false

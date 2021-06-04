extends Control

const NAME = "mainmenu"
onready var parent_scene = null

func _ready():
	pass
	
func enter(host):
	
	parent_scene = host
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	show()


func exit(host):
	
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	queue_free()


func _on_SPButton_pressed():
	pass # Replace with function body.


func _on_MPButton_pressed():
	parent_scene.play_click_sound()
	parent_scene._change_scene("loginmenu")
	


func _on_SettingButton_pressed():
	parent_scene.play_click_sound()
	parent_scene._change_scene("settings")


func _on_QuitButton_pressed():
	parent_scene.play_click_sound()
	parent_scene._quit()

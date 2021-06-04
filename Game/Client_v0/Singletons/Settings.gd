extends Node

signal setting_changed

const SAVE_PATH = "user://config.cfg"

var _config_file = ConfigFile.new()
var _is_setting_loaded =false




var _settings = {
	"gateway":
		{
			"ip":"127.0.0.1",
			"port":1910
		},
	"server":
		{
			"ip":"127.0.0.1",
			"port":1909
		}
}
func _ready():
	#save_settings()
	load_settings()

func load_settings():
	# load setting from config file
	var error = _config_file.load(SAVE_PATH)
	if error != OK:
		print("file not found!")
		return []
	else:
		for section in _settings.keys():
			for key in _settings[section]:
				_settings[section][key] = _config_file.get_value(section ,key ,null)
	
	_is_setting_loaded = true
			
		

func save_settings():
	#save setting to config file
	for section in _settings.keys():
		for key in _settings[section]:
			_config_file.set_value(section ,key ,_settings[section][key])
			
	_config_file.save(SAVE_PATH)
	
	send_setting_changed()
	

func send_setting_changed():
	
	var setting_conn
	if not is_connected("setting_changed" ,get_node("../SceneHandler"),"_setting_reload"):
		setting_conn = connect("setting_changed",get_node("../SceneHandler"),"_setting_reload")
	if not is_connected("setting_changed" ,get_node("../Server"),"_load_settings"):
		setting_conn = connect("setting_changed",get_node("../Server"),"_load_settings")
	if not is_connected("setting_changed" ,get_node("../Gateway"),"_load_settings"):
		setting_conn =connect("setting_changed",get_node("../Gateway"),"_load_settings")
	emit_signal("setting_changed")
	
func get_section(section):
	#getter section
	return _settings[section]

func set_section(section ,key ,value):
	_settings[section][key]= value
	
func user_data(data):
	var f = File.new()
	var err = f.open_encrypted_with_pass("user://savedata.bin", File.WRITE, OS.get_unique_id())
	f.store_var(data)
	f.close()

#client side gateway

extends Node

#primary network 
var network #= NetworkedMultiplayerENet.new()
#secondary network api for gateway -> authorization
var gateway_api #= MultiplayerAPI.new()
var ip 
var port
var cert = load("res://Resources/Certificate/x509_Certificate.crt")
#connected to gateway
var CONNECTED = false

var username 
var password
var new_account = false

var scene_handler

func _ready():
	pass
	
func _load_settings():
	ip = Settings.get_section("gateway")["ip"]
	port = Settings.get_section("gateway")["port"]
	print("Gateway:setting reloaded")

func _process(delta):
	#check whether custom multiplayer api is set
	if  get_custom_multiplayer() == null:
		return
	#check whether custom multiplayer network is set
	if not custom_multiplayer.has_network_peer():
		return
	#start custom_multiplayer poll
	custom_multiplayer.poll();

func ConnectToServer(_username ,_password ,_new_account):
	#set scene handler variable for later use
	scene_handler = get_node("../SceneHandler")
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	#using dtls encryption
	network.set_dtls_enabled(true)
	#set to true when using signed certificate
	network.set_dtls_verify_enabled(false)
	network.set_dtls_certificate(cert)
	
	username = _username
	password = _password
	new_account = _new_account
	
	ip = Settings.get_section("gateway")["ip"]
	port = Settings.get_section("gateway")["port"]
	
	#create connetion to gateway
	network.create_client(ip ,int(port))
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	#connect signals
	network.connect("connection_failed" ,self ,"_OnConnectionFailed")
	network.connect("connection_succeeded" ,self ,"_OnConnectionSucceeded")

func _OnConnectionFailed():
	#on connection failed enable login button
	scene_handler.dismiss_info()
	scene_handler.set_alert("Failed to connect to Login Server.\nPop-up Server offline.")
	get_node("../SceneHandler/LoginScreen").enable_buttons()
	CONNECTED = false
	StateMachine._is_gateway_connected = false
	

func _OnConnectionSucceeded():

	scene_handler.dismiss_info()
	print("Succesfully connected to login server")
	CONNECTED = true
	#state_machine variable update
	StateMachine._is_gateway_connected = true
	
	if new_account == true:
		RequestCreateAccount()
	else:
		#on connection success request login
		RequestLogin()

func RequestLogin():
	print("Connecting to gateway to request login")
	#make login request to gateway
	rpc_id(1,"LoginRequest", username ,password)
	username = ""
	password = ""

remote func ReturnLoginRequest(results,token):
	print("result received")
	#login success
	if results == true:
		#connect to game server
		scene_handler.set_info("Login success.\nConnecting to server ...")
		Server.token = token
		Server.ConnectToServer()
		#remove login screen
		#scene_handler.dismiss_info()
		#scene_handler._play_game()
		
		
		
	else:
		#login failed
		scene_handler.set_alert("Please provide correct username and password")
		get_node("../SceneHandler/LoginScreen").enable_buttons()
		#disconnect signals for gateway
	network.disconnect("connection_failed" ,self ,"_OnConnectionFailed")
	network.disconnect("connection_succeeded" ,self ,"_OnConnectionSucceeded")
	network.close_connection()
	CONNECTED = false
	

func RequestCreateAccount():
	print("Requesting new account")
	rpc_id(1 ,"CreateAccountRequest", username ,password)
	username =""
	password =""
	
remote func ReturnCreateAccountRequest(results , message):
	print("result received")
	scene_handler.dismiss_info()
	if results == true:
		scene_handler.set_alert("Account created please proceed with logging in")
		get_node("../SceneHandler/LoginScreen").enable_buttons()
		get_node("../SceneHandler/LoginScreen")._on_BackButton_pressed()
	else:
		if message == 1:
			scene_handler.set_alert("Couldn't create account ,please try again")
		elif message == 2:
			scene_handler.set_alert("Username already exists, please use a different username")
		get_node("../SceneHandler/LoginScreen").enable_buttons()
		#disconnect signals for gateway
	network.disconnect("connection_failed" ,self ,"_OnConnectionFailed")
	network.disconnect("connection_succeeded" ,self ,"_OnConnectionSucceeded")
	network.close_connection()
	CONNECTED = false

	

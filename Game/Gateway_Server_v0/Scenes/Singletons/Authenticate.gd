#gateway client connect authenticate server
"""
	--ip:Authenticate server ip
	--port1: authenticate server port
	--port2:gateway port
"""
extends Node
#setup network for client 
var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1911
var gateway_port = 1910

func _ready():
	
	var arguments = {}
	
	for argument in OS.get_cmdline_args():
		
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			
			var key_value = argument.split("=")
			var arg_key = key_value[0].lstrip("--")
			
			if "authPort"==arg_key and key_value[1] != "":
				port = int(key_value[1])
			
			elif "clientPort"==arg_key and key_value[1] != "":
				gateway_port = int(key_value[1])
				
			elif "authIP"==arg_key and key_value[1] != "":
				ip = key_value[1]
			else:
				print("Use --clientPort=<port:int> to Client connecting port /nUse --authPort=<port:int> to AuthServer port --ip=<ip:str> for AuthServer IP")
				get_tree().quit(-1)
	

	ConnectToServer()

func ConnectToServer():
	network.create_client(ip ,port)
	get_tree().set_network_peer(network)
	
	

	network.connect("connection_failed" ,self ,"_OnConnectionFailed")
	network.connect("connection_succeeded" ,self ,"_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to connect to authenticate server")

func _OnConnectionSucceeded():
	print("Connected to Authenticate server on ",ip ," :",port)


func AuthenticatePlayer(username , password ,player_id):
	print("sending out authentication request")
	#send authenticate request
	rpc_id(1 ,"AuthenticatePlayer" ,username ,password ,player_id) 
	
remote func AuthenticateResults(result, player_id,token):
	print("results received and replying to player login request")
	Gateway.ReturnLoginRequest(result, player_id,token)

func CreateAccount(username ,password , player_id):
	print("sending out create account request")
	rpc_id(1 ,"CreateAccount",username ,password, player_id)
	
remote func CreateAccountResults(result, player_id , message):
	print("results received and replying to player create account request")
	Gateway.ReturnCreateAccountRequest(result, player_id ,message)
	

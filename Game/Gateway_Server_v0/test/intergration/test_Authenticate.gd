#gateway client connect authenticate server
extends "res://addons/gut/test.gd"

var gateway_script = load("res://test/intergration/test_gateway.gd")
var TestGateway
#setup network for client 
var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1911
var gateway_port = 1910

func before_all():
	add_child_autofree(self)
	TestGateway = autofree(double(gateway_script).new())
	network.create_client(ip ,port)
	get_tree().set_network_peer(network)
	network.connect("connection_failed" ,self ,"_OnConnectionFailed")
	network.connect("connection_succeeded" ,self ,"_OnConnectionSucceeded")


func test_authserver_connection():
	watch_signals(network)
	assert_signal_emitted(network,"connection_succeeded")
	

func _OnConnectionFailed():
	pass

func _OnConnectionSucceeded():
	pass


func AuthenticatePlayer(username , password ,player_id):
	#send authenticate request
	rpc_id(1 ,"AuthenticatePlayer" ,username ,password ,player_id) 
	
remote func AuthenticateResults(result, player_id,token):
	print("results received and replying to player login request")
	TestGateway.ReturnLoginRequest(result, player_id,token)

func CreateAccount(username ,password , player_id):
	print("sending out create account request")
	rpc_id(1 ,"CreateAccount",username ,password, player_id)
	
remote func CreateAccountResults(result, player_id , message):
	print("results received and replying to player create account request")
	TestGateway.ReturnCreateAccountRequest(result, player_id ,message)
	

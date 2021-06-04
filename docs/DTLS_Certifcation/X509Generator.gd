extends Node

var X509_cert_filename = "X509_Certificate.crt"   #certificate name
var X509_key_filename = "x509_Key.key"            #key name

#path to save the files
onready var X509_cert_path = "user://Certificate/" + X509_cert_filename
onready var X509_key_path = "user://Certificate/" + X509_key_filename

var CN = " "     #issuer name
var O = " "      #your organization name
var C = " "     #ISO 3166 code of the country based on

#certification validity period (2021-01-15 00.00.00 t0 2022-01-14 23.59.00 )
var not_before = "20210115000000" 
var not_after = "20220114235900"

func _ready():
	var directory = Directory.new()
	if directory.dir_exists("user://Certificate"):
		pass
	else:
		directory.make_dir("user://Certificate")
	CreateX509Cert()
	print("Certification Created")
	
func CreateX509Cert():
	var CNOC = "CN=" + CN + ",O=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var X509_cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	X509_cert.save(X509_cert_path)
	crypto_key.save(X509_key_path)
	


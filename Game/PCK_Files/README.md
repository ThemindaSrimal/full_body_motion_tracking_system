
# **How to run servers** :

-   Download and extract Godot_v3.2.3-stable_linux_headless.64 

## OR
- run run.sh and replace following "Godot_v3.2.3-stable_linux_headless.64" with "godot" (For AWS)

- *Optional*: creating .\_sc\_ file will make editor_data folder which hold application data in the current directory

## **For Authentication server** :
- ./Godot_v3.2.3-stable_linux_headless.64 --main-pack AuthServer.pck --port1:port_for_gameserver_connection --port2:port_for_gateway_connection
-  By default port1:1912 port2:1911


## **For Gateway server** :
- ./Godot_v3.2.3-stable_linux_headless.64 --main-pack GatewayServer.pck --ip:ip_of_authenticate_server --port1:port_for_authenticate_server_connection --port2:port_for_client_connection
- By default ip:127.0.0.1 port1:1911 port2:1910

## **For Game server** :
- ./Godot_v3.2.3-stable_linux_headless.64 --main-pack Server.pck --ip:ip_of_authenticate_server --port1:port_for_authenticate_server_connection --port2:port_for_client_connection
- By default ip:127.0.0.1 port1:1912 port2:1909



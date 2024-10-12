extends Control

@export var button_host_game: Button
@export var button_join_game: Button

var lobby_name_temp := "LobbyName"
var lobby_password := "LobbyPassword"

var p1_peer := WebSocketMultiplayerPeer.new()
var p2_peer := WebSocketMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_host_game.pressed.connect(_on_button_host_game_pressed)
	button_join_game.pressed.connect(_on_button_join_game_pressed)
	GDSync.connected.connect(connected)
	GDSync.connection_failed.connect(connection_failed)
	GDSync.lobby_created.connect(lobby_created)
	GDSync.lobby_joined.connect(lobby_joined)
	GDSync.lobby_join_failed.connect(lobby_join_failed)
	GDSync.client_joined.connect(client_joined)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	p1_peer.poll()
	p2_peer.poll() # Keep peer open also for the client
	if p1_peer.get_available_packet_count() > 0:
		print("get_available_packet_count: " + str(p1_peer.get_available_packet_count()))
		var packet = p1_peer.get_packet()
		if packet != null:
			var data_string = packet.get_string_from_utf8()
			var data = JSON.parse_string(data_string)
			print(data)

func _on_button_host_game_pressed():
	print("_on_button_host_game_pressed")
	print("Trying to connect to the server...")
	GDSync.start_multiplayer()
	p1_peer.create_server(8915)
	print("Started WebRTC Server")

func _on_button_join_game_pressed():
	print("_on_button_join_game_pressed")
	print("Trying to connect to the server...")
	p2_peer.create_client("ws://[2001:9e8:db14:ba00:400d:437a:7365:3331]:8915")
	#p2_peer.create_client("ws://127.0.0.1:8915")
	print("Started WebRTC Client. Trying to send data...")
	var message = {
		"data": "test"
	}
	var message_bytes = JSON.stringify(message).to_utf8_buffer()
	p2_peer.put_packet(message_bytes)

func connected():
	# creating the lobby
	print("Connected to server. Try to create lobby...")
	GDSync.create_lobby(
		lobby_name_temp,
		lobby_password,
		false, #public ?
		2, #PlayerLimit
		{
			"Gamemode" : "Co-op"
		}
	)

func connection_failed(error : int):
#	Connection failed. Display the possible error messages
	match(error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			print("The public or private key you entered were invalid.")
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			print("Unable to connect, please check your internet connection.")


func lobby_created(lobby_name : String):
#	Lobby created! After a lobby is created you can join it.
	GDSync.join_lobby(lobby_name, lobby_password)
	print("Created Lobby successfull, try to join...")

func lobby_joined(_lobby_name : String):
#	Succesfully joined a lobby! Continue on to the lobby screen
	#get_tree().change_scene_to_file("res://Menus/lobby.tscn")
	print("Lobby successfully joined.")

func lobby_join_failed(lobby_name : String, error : int):
#	Failed to join the lobby. Display error message
	match(error):
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_DOES_NOT_EXIST:
			print("The lobby "+lobby_name+" does not exist.")
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_CLOSED:
			print("The lobby "+lobby_name+" is closed.")
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_FULL:
			print("The lobby "+lobby_name+" is full.")
		ENUMS.LOBBY_JOIN_ERROR.INCORRECT_PASSWORD:
			print("The password for lobby "+lobby_name+" was incorrect.")
		ENUMS.LOBBY_JOIN_ERROR.DUPLICATE_USERNAME:
			print("The lobby "+lobby_name+" already contains your username.")

func client_joined(client_id : int):
	var tcp_server := TCPServer.new()
	var own_client_id := GDSync.get_client_id()
#	Get their username using their Client ID. Give an optinoal fallback for if "Username" does not exist
	var player_user_name = GDSync.get_player_data(client_id, "Username", "Unkown")
	var all_player_data = GDSync.get_all_player_data(client_id)
	var own_client_ip = IP.get_local_addresses() 
	print("============================")
	print("Joined Lobby!")
	print("Own Client ID: " + str(own_client_id))
	for ip in own_client_ip:
		print("Own Client IP: " + str(ip))
	print("Client ID of joined player: " + str(client_id))
	print("Player user Name: " + str(player_user_name))
	print("All player data: " + str(all_player_data))
	print("TCP Server data: " + str(tcp_server))
	print("TCP Server local_port: " + str(tcp_server.get_local_port()))
	print("============================")
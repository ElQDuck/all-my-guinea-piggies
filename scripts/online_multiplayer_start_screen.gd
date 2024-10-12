extends Control

@export var button_host_game: Button
@export var button_join_game: Button
@export var button_joffer: Button

var peer_connection : WebRTCPeerConnection

var lobby_name_temp := "LobbyName"
var lobby_password := "LobbyPassword"

var self_id: int = 1
var other_player_id: int = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_host_game.pressed.connect(_on_button_host_game_pressed)
	button_join_game.pressed.connect(_on_button_join_game_pressed)
	button_joffer.pressed.connect(_on_button_joffer_pressed)
	GDSync.connected.connect(connected)
	GDSync.connection_failed.connect(connection_failed)
	GDSync.lobby_created.connect(lobby_created)
	GDSync.lobby_joined.connect(lobby_joined)
	GDSync.lobby_join_failed.connect(lobby_join_failed)
	GDSync.client_joined.connect(client_joined)
	print("Trying to connect to the server...")
	GDSync.start_multiplayer()
	
	# Initialize WebRTC Peer Connection
	peer_connection = WebRTCPeerConnection.new()
	peer_connection.session_description_created.connect(_on_session_description_created)
	peer_connection.ice_candidate_created.connect(_on_ice_candidate_created)
	peer_connection.data_channel_received.connect(_on_data_channel_received)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_session_description_created(type, sdp):
	var message = {"type": type, "sdp": sdp}
	var messageJson = JSON.stringify(message)
	#gd_sync.send_message(to_json(message))
	# Here call _on_gd_sync_message_received() on the other players mashine.
	# Iy self = p1 then p2._on_gd_sync_message_received() and vice versa
	# with: GDSync.call_func_on(client_id, _receive_message, [text, _current_typing_channel, GDSync.get_client_id()])
	print("Offer created. Sending data: " + messageJson)
	GDSync.call_func_on(other_player_id, _on_gd_sync_message_received, [messageJson])

func _on_ice_candidate_created(candidate):
	var message = {"type": "candidate", "candidate": candidate}
	var messageJson = JSON.stringify(message)
	#gd_sync.send_message(to_json(message))
	# Here call _on_gd_sync_message_received() on the other players mashine.
	# Iy self = p1 then p2._on_gd_sync_message_received() and vice versa
	# with: GDSync.call_func_on(client_id, _receive_message, [text, _current_typing_channel, GDSync.get_client_id()])
	print("Ice candidate created. Sending data: " + messageJson)
	GDSync.call_func_on(other_player_id, _on_gd_sync_message_received, [messageJson])

func _on_data_channel_received(channel):
	channel.connect("data_received", self, "_on_data_channel_data_received")

func _on_button_host_game_pressed():
	print("_on_button_host_game_pressed")
	print("Trying to create lobby.")
	GDSync.create_lobby(
		lobby_name_temp,
		lobby_password,
		false, #public ?
		2, #PlayerLimit
		{
			"Gamemode" : "Co-op"
		}
	)

func _on_button_join_game_pressed():
	print("_on_button_join_game_pressed")
	print("Trying to connect to the lobby...")
	GDSync.join_lobby(lobby_name_temp, lobby_password)

func connected():
	# creating the lobby
	print("Connected to server.")

func connection_failed(error : int):
#	Connection failed. Display the possible error messages
	match(error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			print("The public or private key you entered were invalid.")
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			print("Unable to connect, please check your internet connection.")


func lobby_created(lobby_name : String):
#	Lobby created! After a lobby is created you can join it.
	print("Created Lobby successfull.")

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
	self_id = GDSync.get_client_id()
	if client_id != self_id:
		other_player_id = client_id
#	Get their username using their Client ID. Give an optinoal fallback for if "Username" does not exist
	var player_user_name = GDSync.get_player_data(client_id, "Username", "Unkown")
	var all_player_data = GDSync.get_all_player_data(client_id)
	print("============================")
	print("Joined Lobby!")
	print("Client ID of joined player: " + str(client_id))
	print("Player user Name: " + str(player_user_name))
	print("All player data: " + str(all_player_data))
	print("============================")

# This function has to be called by the connected client
func _on_gd_sync_message_received(message):
	print("_on_gd_sync_message_received called with: " + message)
	var data = JSON.parse_string(message)
	if data["type"] == "offer":
		peer_connection.set_remote_description("offer", data["sdp"])
		peer_connection.create_answer()
	elif data["type"] == "answer":
		peer_connection.set_remote_description("answer", data["sdp"])
	elif data["type"] == "candidate":
		peer_connection.add_ice_candidate(data["candidate"], 0, "test")

func _on_button_joffer_pressed():
	print("Creating an offer...")
	peer_connection.create_offer()
# E 0:00:24:0337   online_multiplayer_start_screen.gd:145 @ _on_button_joffer_pressed(): Required virtual method WebRTCPeerConnectionExtension::_create_offer must be overridden before calling.
#   <C++ Source>   modules/webrtc/webrtc_peer_connection_extension.h:53 @ _gdvirtual__create_offer_call()
#   <Stack Trace>  online_multiplayer_start_screen.gd:145 @ _on_button_joffer_pressed()

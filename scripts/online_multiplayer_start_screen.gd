# A lot of code copied from https://github.com/godotengine/godot-demo-projects/tree/master/networking/webrtc_signaling
extends Control

enum Message {
	JOIN,
	ID,
	PEER_CONNECT,
	PEER_DISCONNECT,
	OFFER,
	ANSWER,
	CANDIDATE,
	SEAL,
}

@export var button_host_create_gdsync_lobby: Button
@export var button_host_join_gdsync_lobby: Button
@export var button_client_join_gdsync_lobby: Button
@export var button_host_send_rtc_invite: Button
@export var button_host_send_gdsync_message: Button
@export var button_client_send_gdsync_message: Button
@export var button_host_send_rtc_message: Button
@export var button_client_send_rtc_message: Button

var peer_connection := WebRTCPeerConnection.new()
var peer_data_channel := peer_connection.create_data_channel("test_channel", {"id": 1, "negotiated": true})

var lobby_name_temp := "LobbyName"
var lobby_password := "LobbyPassword"

# TODO better id management
var self_id: int = 1
var other_player_id: int = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_host_create_gdsync_lobby.pressed.connect(_on_button_create_gdsync_lobby_pressed)
	button_host_join_gdsync_lobby.pressed.connect(_on_button_join_lobbby_pressed)
	button_client_join_gdsync_lobby.pressed.connect(_on_button_join_lobbby_pressed)
	button_host_send_rtc_invite.pressed.connect(_on_button_host_send_invite_pressed)
	button_host_send_gdsync_message.pressed.connect(_on_button_host_send_gdsync_message_pressed)
	button_client_send_gdsync_message.pressed.connect(_on_button_client_send_gdsync_message_pressed)
	button_host_send_rtc_message.pressed.connect(_on_button_host_send_rtc_message_pressed)
	button_client_send_rtc_message.pressed.connect(_on_button_client_send_rtc_message_pressed)

	GDSync.connected.connect(connected)
	GDSync.connection_failed.connect(connection_failed)
	GDSync.lobby_created.connect(_on_lobby_successful_created)
	GDSync.lobby_joined.connect(lobby_joined)
	GDSync.lobby_join_failed.connect(lobby_join_failed)
	GDSync.client_joined.connect(client_joined)
	# This is necessary to make the function callable from other machines
	GDSync.expose_func(_on_gd_sync_message_received)
	GDSync.expose_func(_on_gd_sync_rtc_info_received)
	GDSync.expose_func(_on_gd_sync_ice_candidate_info_received)
	print("Trying to connect to the server...")
	GDSync.start_multiplayer()

	# WebRtc setup
	#peer_connection = WebRTCPeerConnection.new()
	var rtc_init_result = peer_connection.initialize({"iceServers": [ { "urls": ["stun:stun.l.google.com:19302", "stun:stun1.l.google.com:19302"] } ]})
	print("peer_connection.initialize result: " + str(rtc_init_result))
	peer_connection.session_description_created.connect(_on_session_description_created)
	peer_connection.ice_candidate_created.connect(_on_ice_candidate_created)
	peer_data_channel = peer_connection.create_data_channel("test_channel", {"id": 1, "negotiated": true})
	var channel_id := peer_data_channel.get_id()
	print("channel state: " + str(channel_id))

func _process(_delta):
	peer_connection.poll()
	if peer_data_channel.get_ready_state() == peer_data_channel.STATE_OPEN and peer_data_channel.get_available_packet_count() > 0:
		print("rtc received: ", peer_data_channel.get_packet().get_string_from_utf8())

func _on_session_description_created(type: String, sdp: String) -> void:
	# Send the offer to the signaling server
	var message = {"type": type, "sdp": sdp}
	var message_json = JSON.stringify(message)
	peer_connection.set_local_description(type, sdp)
	GDSync.call_func_on(other_player_id, _on_gd_sync_rtc_info_received, [message_json])


func _on_button_host_send_gdsync_message_pressed() -> void:
	print("Host: Sending GD Sync message to client...")
	var message = {"client_type": "Host", "message": "Hello from host."}
	var messageJson = JSON.stringify(message)
	GDSync.call_func_on(other_player_id, _on_gd_sync_message_received, [messageJson])

func _on_button_client_send_gdsync_message_pressed() -> void:
	print("Client: Sending GD Sync message to host...")
	var message = {"client_type": "Client", "message": "Hello from client."}
	var messageJson = JSON.stringify(message)
	GDSync.call_func_on(other_player_id, _on_gd_sync_message_received, [messageJson])

func _on_button_host_send_rtc_message_pressed() -> void:
	print("Host: Sending RTC message to client...")
	peer_data_channel.put_packet("Hi from RTC Host".to_utf8_buffer())

func _on_button_client_send_rtc_message_pressed() -> void:
	print("Client: Sending RTC message to host...")
	peer_data_channel.put_packet("Hi from RTC Client".to_utf8_buffer())

func _on_ice_candidate_created(media: String, index: int, ice_name: String) -> void:
	var message = {"media": media, "index": index, "name": ice_name}
	var messageJson = JSON.stringify(message)
	print("Ice candidate created. Sending data: " + messageJson)
	GDSync.call_func_on(other_player_id, _on_gd_sync_ice_candidate_info_received, [messageJson])

func _on_data_channel_received(channel):
	channel.connect("data_received", self, "_on_data_channel_data_received")

func _on_button_create_gdsync_lobby_pressed():
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

func _on_button_join_lobbby_pressed():
	print("_on_button_join_lobbby_pressed")
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


func _on_lobby_successful_created(lobby_name : String):
#	Lobby created! After a lobby is created you can join it.
	print("Lobby with name '" + lobby_name + "' successfull created.")
	lobby_name_temp = lobby_name


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
func _on_gd_sync_message_received(message: String):
	print("_on_gd_sync_message_received called with: " + message)
	var data = JSON.parse_string(message)
	print("Client: " + data["client_type"])
	print("Message: " + data["message"])

func _on_gd_sync_rtc_info_received(message: String):
	print("_on_gd_sync_rtc_info_received called with: " + message)
	var rtc_data = JSON.parse_string(message)
	print("type: " + rtc_data["type"])
	print("sdp: " + rtc_data["sdp"])
	peer_connection.set_remote_description(rtc_data["type"], rtc_data["sdp"])

func _on_gd_sync_ice_candidate_info_received(message: String):
	print("_on_gd_sync_ice_candidate_info_received called with: " + message)
	var rtc_data = JSON.parse_string(message)
	print("media: " + rtc_data["media"])
	print("index: " + str(rtc_data["index"]))
	print("name: " + rtc_data["name"])
	peer_connection.add_ice_candidate(rtc_data["media"], rtc_data["index"], rtc_data["name"])


func _on_button_host_send_invite_pressed():
	print("Creating an offer...")
	var create_offer_result = peer_connection.create_offer()
	print("peer_connection.create_offer result: " + str(create_offer_result))

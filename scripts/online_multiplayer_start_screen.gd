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

var peer_connection : WebRTCPeerConnection
var web_rtc_data_channel : WebRTCDataChannel
var rtc_mp := WebRTCMultiplayerPeer.new()
var ws := WebSocketPeer.new()

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
	print("Trying to connect to the server...")
	GDSync.start_multiplayer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#web_rtc_data_channel.poll()

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

func _on_button_client_send_rtc_message_pressed() -> void:
	print("Client: Sending RTC message to host...")

func _on_offer_created(type: String, data: String, id: int) -> void:
	# type and data from: peer_connection.session_description_created.connect()
	if not rtc_mp.has_peer(id):
		return
	print("created", type)
	print("data", data)
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer": send_offer(id, data)
	else: send_answer(id, data)

##########################################################
	#var message = {"type": type, "sdp": sdp}
	#var messageJson = JSON.stringify(message)
	#gd_sync.send_message(to_json(message))
	# Here call _on_gd_sync_message_received() on the other players mashine.
	# Iy self = p1 then p2._on_gd_sync_message_received() and vice versa
	# with: GDSync.call_func_on(client_id, _receive_message, [text, _current_typing_channel, GDSync.get_client_id()])
	print("Offer created. Sending data: " + data)
	GDSync.call_func_on(other_player_id, _on_gd_sync_message_received, [data])

func _on_ice_candidate_created(candidate):
	var message = {"type": "candidate", "candidate": candidate}
	var messageJson = JSON.stringify(message)
	#gd_sync.send_message(to_json(message))
	# Here call _on_gd_sync_message_received() on the other players mashine.
	# Iy self = p1 then p2._on_gd_sync_message_received() and vice versa
	# with: GDSync.call_func_on(client_id, _receive_message, [text, _current_typing_channel, GDSync.get_client_id()])
	print("Ice candidate created. Sending data: " + messageJson)
	GDSync.call_func_on(other_player_id, _on_gd_sync_message_received, [messageJson])

func _on_new_ice_candidate(mid_name: String, index_name: int, sdp_name: String, id: int) -> void:
	send_candidate(id, mid_name, index_name, sdp_name)

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
	# if data["type"] == "offer":
	# 	peer_connection.set_remote_description("offer", data["sdp"])
	# 	peer_connection.create_answer()
	# elif data["type"] == "answer":
	# 	peer_connection.set_remote_description("answer", data["sdp"])
	# elif data["type"] == "candidate":
	# 	peer_connection.add_ice_candidate(data["candidate"], 0, "test")

func _on_button_host_send_invite_pressed():
	print("Creating an offer...")
	# Initialize WebRTC Peer Connection
	peer_connection = WebRTCPeerConnection.new()
	peer_connection.initialize({"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]})
	# Add a function which will be called when an offer gets created
	# TODO change hardcoded ID
	peer_connection.session_description_created.connect(_on_offer_created.bind(self_id))
	# Add a function which will be called when an ice candidate is created
	peer_connection.ice_candidate_created.connect(_on_new_ice_candidate.bind(self_id))
	# Adding the created peer to the WebRTCMultiplayerPeer
	rtc_mp.add_peer(peer_connection, self_id)
	var offer_created = peer_connection.create_offer()
	print("Creating offer result: " + str(offer_created))

func send_candidate(id: int, mid: String, index: int, sdp: String) -> Error:
	return _send_msg(Message.CANDIDATE, id, "\n%s\n%d\n%s" % [mid, index, sdp])

func send_offer(id: int, offer: String) -> Error:
	return _send_msg(Message.OFFER, id, offer)

func send_answer(id: int, answer: String) -> Error:
	return _send_msg(Message.ANSWER, id, answer)

# TODO: CHange this to use GDSync instead of ws
func _send_msg(type: int, id: int, data: String = "") -> Error:
	# Error return value description: https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html#enum-globalscope-error
	var messageJson = JSON.stringify({
		"type": type,
		"id": id,
		"data": data,
	})
	GDSync.call_func_on(other_player_id, _on_gd_sync_message_received, [messageJson])
	return Error.OK

extends Control

@export var button_host_game: Button

var lobby_name_temp := "LobbyName"
var lobby_password := "LobbyPassword"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_host_game.pressed.connect(_on_button_host_game_pressed)
	GDSync.connected.connect(connected)
	GDSync.connection_failed.connect(connection_failed)
	GDSync.lobby_created.connect(lobby_created)
	GDSync.lobby_joined.connect(lobby_joined)
	GDSync.lobby_join_failed.connect(lobby_join_failed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_host_game_pressed():
	print("_on_button_host_game_pressed")
	print("Trying to connect to the server...")
	GDSync.start_multiplayer()

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
extends Control

@export var start_local_game_button: Button
@export var start_online_game_button: Button
@export var language_button: TextureButton

# Called when the node enters the scene tree for the first time.
func _ready():
	start_local_game_button.pressed.connect(_on_start_local_game_button_pressed)
	start_online_game_button.pressed.connect(_on_start_online_game_button_pressed)
	language_button.pressed.connect(_change_language)
	
	var language := TranslationServer.get_locale()
	match language:
		"de_DE", "de":
			language_button.set_texture_normal(load("res://assets/flags/de.svg"))
		"en":
			language_button.set_texture_normal(load("res://assets/flags/sh.svg"))
		"no", "nb", "nb_NO":
			language_button.set_texture_normal(load("res://assets/flags/no.svg"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_local_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/profile_setup.tscn")

func _on_start_online_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/profile_setup.tscn")


func _change_language():
	var language := TranslationServer.get_locale()
	match language:
		"de_DE", "de":
			TranslationServer.set_locale("en")
			language_button.set_texture_normal(load("res://assets/flags/sh.svg"))
		"en":
			TranslationServer.set_locale("no")
			language_button.set_texture_normal(load("res://assets/flags/no.svg"))
		"no", "nb", "nb_NO":
			TranslationServer.set_locale("de")
			language_button.set_texture_normal(load("res://assets/flags/de.svg"))

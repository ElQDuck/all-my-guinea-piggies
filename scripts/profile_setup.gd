extends Control

@export var player_1: Control
@export var player_2: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	player_1.ready_button.pressed.connect(_toggled_ready_button)
	player_2.ready_button.pressed.connect(_toggled_ready_button)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _toggled_ready_button():
	# If both players are ready swith the scene
	if player_1.customisation_ready == true and player_2.customisation_ready == true:
		_switch_scene()


func _switch_scene():
	# Saving the players selected values in the global variables stored global_vars.gd script running at startup (autoload)
	GlobalVars.player_1["name"] = player_1.selected_player_name
	GlobalVars.player_1["selected_image_index"] = player_1.selected_image_index
	GlobalVars.player_1["color_combinations"] = player_1.color_combinations[player_1.selected_color_index]
	GlobalVars.player_2["name"] = player_2.selected_player_name
	GlobalVars.player_2["selected_image_index"] = player_2.selected_image_index
	GlobalVars.player_2["color_combinations"] = player_2.color_combinations[player_2.selected_color_index]
	get_tree().change_scene_to_file("res://scenes/game.tscn")

extends CanvasLayer

@export var ui_panel: Panel

@export var player_1_panel: Panel
@export var player_1_image: TextureRect
@export var player_1_image_panel: Panel
@export var player_1_name_label: Label
@export var player_1_name_panel: Panel
@export var player_1_score_label: Label
var player_1_colors := {"primary": Color("ff6b6b"),
	"secondary": Color("f7b7bb"),
	"font_color": Color("ffffff"),
	"complementary_primary": Color("2fadcc"),
	"complementary_secondary": Color("d0ecff"),
	"complementary_font_color": Color("000000")}

@export var player_2_panel: Panel
@export var player_2_image: TextureRect
@export var player_2_image_panel: Panel
@export var player_2_name_label: Label
@export var player_2_name_panel: Panel
@export var player_2_score_label: Label
var player_2_colors := {"primary": Color("ff6b6b"),
	"secondary": Color("f7b7bb"),
	"font_color": Color("ffffff"),
	"complementary_primary": Color("2fadcc"),
	"complementary_secondary": Color("d0ecff"),
	"complementary_font_color": Color("000000")}

@export var button: Button


# Called when the node enters the scene tree for the first time.
func _ready():
	button.pressed.connect(_handle_button_click)
	
	# Player 1
	player_1_image.texture = load("res://assets/avatar_images/profile" + str(GlobalVars.player_1["selected_image_index"]) + ".png")
	player_1_name_label.text = GlobalVars.player_1["name"]
	player_1_colors = GlobalVars.player_1["color_combinations"]
	# ProfileColors
	var profileBorderStyleBox: StyleBoxFlat = player_1_image_panel.get_theme_stylebox("panel").duplicate()
	profileBorderStyleBox.set("bg_color", player_1_colors["secondary"])
	profileBorderStyleBox.set("border_color", player_1_colors["primary"])
	player_1_image_panel.add_theme_stylebox_override("panel", profileBorderStyleBox)
	var profileLabelBackgroundStyleBox: StyleBoxFlat = player_1_name_panel.get_theme_stylebox("panel").duplicate()
	profileLabelBackgroundStyleBox.set("bg_color", player_1_colors["primary"])
	player_1_name_panel.add_theme_stylebox_override("panel", profileLabelBackgroundStyleBox)
	
	# Player 2
	player_2_image.texture = load("res://assets/avatar_images/profile" + str(GlobalVars.player_2["selected_image_index"]) + ".png")
	player_2_name_label.text = GlobalVars.player_2["name"]
	player_2_colors = GlobalVars.player_2["color_combinations"]
	# ProfileColors
	var profileBorderStyleBox2: StyleBoxFlat = player_2_image_panel.get_theme_stylebox("panel").duplicate()
	profileBorderStyleBox2.set("bg_color", player_2_colors["secondary"])
	profileBorderStyleBox2.set("border_color", player_2_colors["primary"])
	player_2_image_panel.add_theme_stylebox_override("panel", profileBorderStyleBox2)
	var profileLabelBackgroundStyleBox2: StyleBoxFlat = player_2_name_panel.get_theme_stylebox("panel").duplicate()
	profileLabelBackgroundStyleBox2.set("bg_color", player_2_colors["primary"])
	player_2_name_panel.add_theme_stylebox_override("panel", profileLabelBackgroundStyleBox2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _handle_button_click() -> void:
	# Restarting the game
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")


func make_visible(player_1_score: int, player_2_score: int):
	player_1_score_label.set_text(str(player_1_score))
	player_2_score_label.set_text(str(player_2_score))
	if player_1_score >= 77:
		player_1_panel.set_visible(true)
	if player_2_score >= 77:
		player_2_panel.set_visible(true)
	
	ui_panel.set_pivot_offset(ui_panel.get_size() / 2)
	self.set_visible(true)
	var scale_up_tween = create_tween()
	await scale_up_tween.tween_property(ui_panel, "scale", Vector2(1, 1), 0.25).from(Vector2(0, 0)).finished

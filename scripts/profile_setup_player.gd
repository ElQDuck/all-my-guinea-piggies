extends Control

@export var color_preview: Panel
@export var color_button_left: Button
@export var color_button_right: Button
@export var avatar_image: TextureRect
@export var avatar_border: Panel
@export var avatar_button_left: Button
@export var avatar_button_right: Button
@export var input_player_name: LineEdit
@export var ready_button: Button

var customisation_ready: bool = false
var selected_player_name: String = ""
var selected_image_index:int = 0
var selected_color_index: int = 0
var color_combinations: Array = [
	{"primary": Color("ff6b6b"),
	"secondary": Color("ffccd1"),
	"font_color": Color("70e4e4"),
	"complementary_primary": Color("70e4e4"),
	"complementary_secondary": Color("def9f8"),
	"complementary_font_color": Color("ff6b6b")},
	{"primary": Color("70e4e4"),
	"secondary": Color("def9f8"),
	"font_color": Color("ff6b6b"),
	"complementary_primary": Color("ff6b6b"),
	"complementary_secondary": Color("ffccd1"),
	"complementary_font_color": Color("70e4e4")},
	
	{"primary": Color("f457cf"),
	"secondary": Color("fbbdea"),
	"font_color": Color("57f47c"),
	"complementary_primary": Color("57f47c"),
	"complementary_secondary": Color("c2fac9"),
	"complementary_font_color": Color("f457cf")},
	{"primary": Color("57f47c"),
	"secondary": Color("c2fac9"),
	"font_color": Color("f457cf"),
	"complementary_primary": Color("f457cf"),
	"complementary_secondary": Color("fbbdea"),
	"complementary_font_color": Color("57f47c")},
	
	{"primary": Color("4ec4ff"),
	"secondary": Color("b4e6ff"),
	"font_color": Color("ff894e"),
	"complementary_primary": Color("ff894e"),
	"complementary_secondary": Color("ffcbb3"),
	"complementary_font_color": Color("4ec4ff")},
	{"primary": Color("ff894e"),
	"secondary": Color("ffcbb3"),
	"font_color": Color("4ec4ff"),
	"complementary_primary": Color("4ec4ff"),
	"complementary_secondary": Color("b4e6ff"),
	"complementary_font_color": Color("ff894e")},
	
	{"primary": Color("fff200"),
	"secondary": Color("fefabf"),
	"font_color": Color("000dff"),
	"complementary_primary": Color("000dff"),
	"complementary_secondary": Color("bfc3fe"),
	"complementary_font_color": Color("fff200")},
	{"primary": Color("000dff"),
	"secondary": Color("bfc3fe"),
	"font_color": Color("fff200"),
	"complementary_primary": Color("fff200"),
	"complementary_secondary": Color("fefabf"),
	"complementary_font_color": Color("000dff")},
	
	{"primary": Color("32ff7e"),
	"secondary": Color("beffcb"),
	"font_color": Color("f87bdb"),
	"complementary_primary": Color("f87bdb"),
	"complementary_secondary": Color("ffe1f6"),
	"complementary_font_color": Color("32ff7e")},
	{"primary": Color("f87bdb"),
	"secondary": Color("ffe1f6"),
	"font_color": Color("32ff7e"),
	"complementary_primary": Color("32ff7e"),
	"complementary_secondary": Color("beffcb"),
	"complementary_font_color": Color("f87bdb")}
	]
var num_of_avatar_images = 9 # = 10 - 1 because we start the count with 0


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connecting signals
	color_button_left.pressed.connect(_on_color_button_left_pressed)
	color_button_right.pressed.connect(_on_color_button_right_pressed)
	avatar_button_left.pressed.connect(_on_avatar_button_left_pressed)
	avatar_button_right.pressed.connect(_on_avatar_button_right_pressed)
	ready_button.toggled.connect(_on_ready_button_toggled)
	#get_tree().get_root().size_changed.connect(_reset_pivot)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_color_button_left_pressed():
	if selected_color_index == 0:
		selected_color_index = color_combinations.size() - 1
	else:
		selected_color_index -= 1
	_change_panel_bg_color(color_combinations[selected_color_index]["primary"])
	_change_avatar_panel_colors(color_combinations[selected_color_index]["secondary"], color_combinations[selected_color_index]["primary"])


func _on_color_button_right_pressed():
	if selected_color_index == color_combinations.size() - 1:
		selected_color_index = 0
	else:
		selected_color_index += 1
	_change_panel_bg_color(color_combinations[selected_color_index]["primary"])
	_change_avatar_panel_colors(color_combinations[selected_color_index]["secondary"], color_combinations[selected_color_index]["primary"])


func _change_avatar_panel_colors(background_color: Color, border_color: Color):
	var avatarBorderStyleBox: StyleBoxFlat = avatar_border.get_theme_stylebox("panel").duplicate()
	avatarBorderStyleBox.set("bg_color", background_color)
	avatarBorderStyleBox.set("border_color", border_color)
	avatar_border.add_theme_stylebox_override("panel", avatarBorderStyleBox)


func _change_panel_bg_color(color: Color):
	var colorPreviewStyleBox: StyleBoxFlat = color_preview.get_theme_stylebox("panel").duplicate()
	colorPreviewStyleBox.set("bg_color", color)
	color_preview.add_theme_stylebox_override("panel", colorPreviewStyleBox)


func _on_avatar_button_left_pressed():
	if selected_image_index == 0:
		selected_image_index = num_of_avatar_images
	else:
		selected_image_index -= 1
	avatar_image.texture = load("res://assets/avatar_images/profile" + str(selected_image_index) + ".png")


func _on_avatar_button_right_pressed():
	if selected_image_index == num_of_avatar_images:
		selected_image_index = 0
	else:
		selected_image_index += 1
	avatar_image.texture = load("res://assets/avatar_images/profile" + str(selected_image_index) + ".png")


func _on_ready_button_toggled(toggled_on: bool):
	# Disable all player input if toggled
	if toggled_on:
		color_button_left.set_disabled(true)
		color_button_right.set_disabled(true)
		avatar_button_left.set_disabled(true)
		avatar_button_right.set_disabled(true)
		input_player_name.set_editable(false)
		customisation_ready = true
	else:
		color_button_left.set_disabled(false)
		color_button_right.set_disabled(false)
		avatar_button_left.set_disabled(false)
		avatar_button_right.set_disabled(false)
		input_player_name.set_editable(true)
		customisation_ready = false
	
	# Check if name entered otherwise assign a random one
	if toggled_on == true and input_player_name.text == "":
		selected_player_name = str(Card.PiggyType.find_key(randi() % 10 + 1))
	else:
		selected_player_name = input_player_name.text

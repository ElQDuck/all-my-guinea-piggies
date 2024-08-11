extends Node

# Player 1
var player_1 = {
	"name": "Player1",
	"selected_image_index": 0,
	"color_combinations": 
	{"primary": Color("4ec4ff"),
	"secondary": Color("b4e6ff"),
	"font_color": Color("ff894e"),
	"complementary_primary": Color("ff894e"),
	"complementary_secondary": Color("ffcbb3"),
	"complementary_font_color": Color("4ec4ff")}
}

# Player 2
var player_2 = {
	"name": "Player2",
	"selected_image_index": 0,
	"color_combinations":
	{"primary": Color("ff894e"),
	"secondary": Color("ffcbb3"),
	"font_color": Color("4ec4ff"),
	"complementary_primary": Color("4ec4ff"),
	"complementary_secondary": Color("b4e6ff"),
	"complementary_font_color": Color("ff894e")}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

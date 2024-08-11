extends Panel

@export var player_number: int
@export var profile_image: TextureRect
@export var profile_panel: Panel
@export var name_label: Label
@export var name_panel: Panel
@export var progress_label: Label
@export var progress_panel: Panel

var score: int = 0
var colorColection: Dictionary = {
	"primary": Color("ff6b6b"),
	"secondary": Color("f7b7bb"),
	"font_color": Color("000000"),
	"complementary_primary": Color("2fadcc"),
	"complementary_secondary": Color("d0ecff"),
	"complementary_font_color": Color("ffffff")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _update_ui():
	if player_number == 1:
		profile_image.texture = load("res://assets/avatar_images/profile" + str(GlobalVars.player_1["selected_image_index"]) + ".png")
		name_label.text = GlobalVars.player_1["name"]
		colorColection = GlobalVars.player_1["color_combinations"]
	else:
		profile_image.texture = load("res://assets/avatar_images/profile" + str(GlobalVars.player_2["selected_image_index"]) + ".png")
		name_label.text = GlobalVars.player_2["name"]
		colorColection = GlobalVars.player_2["color_combinations"]

	# ProfileColors
	var profileBorderStyleBox: StyleBoxFlat = profile_panel.get_theme_stylebox("panel").duplicate()
	profileBorderStyleBox.set("bg_color", colorColection["secondary"])
	profileBorderStyleBox.set("border_color", colorColection["primary"])
	profile_panel.add_theme_stylebox_override("panel", profileBorderStyleBox)
	var profileLabelBackgroundStyleBox: StyleBoxFlat = name_panel.get_theme_stylebox("panel").duplicate()
	profileLabelBackgroundStyleBox.set("bg_color", colorColection["primary"])
	name_panel.add_theme_stylebox_override("panel", profileLabelBackgroundStyleBox)
	
	# Progress
	progress_panel.material.set("shader_parameter/progress", 0.0)
	progress_label.set_text("0/77")
	#await card_rotation_tween_90.tween_property(card_view_port.material, "shader_parameter/y_rot", -90.0, half_flip_dur).finished


func update_score(score: int) -> void:
	var tween_speed: float = 1.0
	var label_tween = create_tween()
	label_tween.tween_method(_update_score_label, self.score, score, tween_speed)
	var shader_tween = create_tween()
	shader_tween.tween_property(progress_panel.material, "shader_parameter/progress", (1.0 / 77) * score, tween_speed).from_current()
	self.score = score


func _update_score_label(score: int) -> void:
	progress_label.set_text(str(score) + "/77")

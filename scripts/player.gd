extends Control

signal end_turn
signal show_player_cards(cards: Array[Card])

var player_name: String
var profile_image_index: int
var cards_in_hand: Array[Card]
var player_is_active: bool = false
var score: int
var colorColection: Dictionary = {
	"primary": Color("ff6b6b"),
	"secondary": Color("f7b7bb"),
	"font_color": Color("000000"),
	"complementary_primary": Color("2fadcc"),
	"complementary_secondary": Color("d0ecff"),
	"complementary_font_color": Color("ffffff")
}
@export var player_id: int
@export var score_name_label: Label
@export var score_value_label: Label
@export var score_max_value_label: Label
@export var button_end_turn: Button
@export var disable_layer_panel: Panel
@export var disable_layer_avater: Panel
@export var uiPanel: Panel
@export var uiProfileImage: TextureRect
@export var uiProfileImageBorder: Panel
@export var uiNameLabelBackground: Panel
@export var uiPlayerNameLabel: Label
@export var ui_profile_image_button: TextureButton
@export var ui_cards_count_label: Label
@export var ui_cards_count_background_panel: Panel

# CardsInHandUi
@export var cards_in_hand_ui: CanvasLayer
@export var cards_in_hand_ui_box_panel: Panel
@export var cards_in_hand_ui_grid_container: GridContainer
@export var cards_in_hand_ui_header_label: Label
@export var cards_in_hand_ui_close_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	button_end_turn.pressed.connect(_handle_button_click)
	ui_profile_image_button.pressed.connect(_cards_in_hand_ui_visible_on)
	cards_in_hand_ui_close_button.pressed.connect(_cards_in_hand_ui_visible_off)
	ui_cards_count_label.set_text("0")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Adjust the pivot to make rotations around the center
	self.pivot_offset = self.get_size() / 2
	
	if player_is_active:
		disable_layer_panel.set_visible(false)
		disable_layer_avater.set_visible(false)
	else:
		disable_layer_panel.set_visible(true)
		disable_layer_avater.set_visible(true)


func get_player_position() -> Vector2:
	if player_id == 1:
		return uiProfileImage.get_global_position() + uiProfileImage.get_size() / 2
	else:
		return uiProfileImage.get_global_position() - uiProfileImage.get_size() / 2


func _update_ui():	
	# ProfileImage
	uiProfileImage.texture = load("res://assets/avatar_images/profile" + str(profile_image_index) + ".png")
	
	# ProfileName
	uiPlayerNameLabel.text = player_name
	
	# ProfileColors
	var profileBorderStyleBox: StyleBoxFlat = uiProfileImageBorder.get_theme_stylebox("panel").duplicate()
	profileBorderStyleBox.set("bg_color", colorColection["secondary"])
	profileBorderStyleBox.set("border_color", colorColection["primary"])
	uiProfileImageBorder.add_theme_stylebox_override("panel", profileBorderStyleBox)
	var profileLabelBackgroundStyleBox: StyleBoxFlat = uiNameLabelBackground.get_theme_stylebox("panel").duplicate()
	profileLabelBackgroundStyleBox.set("bg_color", colorColection["primary"])
	uiNameLabelBackground.add_theme_stylebox_override("panel", profileLabelBackgroundStyleBox)
	var uiPanelStyleBox: StyleBoxFlat = uiPanel.get_theme_stylebox("panel").duplicate()
	uiPanelStyleBox.set("bg_color", colorColection["secondary"])
	uiPanelStyleBox.set("border_color", colorColection["primary"])
	uiPanel.add_theme_stylebox_override("panel", uiPanelStyleBox)
	
	# Font Colors
	score_name_label.set("theme_override_colors/font_color", colorColection["font_color"])
	score_value_label.set("theme_override_colors/font_color", colorColection["font_color"])
	score_max_value_label.set("theme_override_colors/font_color", colorColection["font_color"])
	uiPlayerNameLabel.set("theme_override_colors/font_color", colorColection["font_color"])
	
	# Button Color
	# Normal
	button_end_turn.set("theme_override_colors/font_color", colorColection["complementary_font_color"])
	button_end_turn.set("theme_override_colors/font_pressed_color", colorColection["complementary_font_color"])
	button_end_turn.set("theme_override_colors/font_focus_color", colorColection["complementary_font_color"])
	var buttonStyleBoxNormal: StyleBoxFlat = button_end_turn.get_theme_stylebox("normal").duplicate()
	buttonStyleBoxNormal.set("bg_color", colorColection["complementary_secondary"])
	buttonStyleBoxNormal.set("border_color", colorColection["complementary_primary"])
	button_end_turn.add_theme_stylebox_override("normal", buttonStyleBoxNormal)
	# Hover
	button_end_turn.set("theme_override_colors/font_hover_color", colorColection["complementary_font_color"])
	var buttonStyleBoxHover: StyleBoxFlat = button_end_turn.get_theme_stylebox("hover").duplicate()
	buttonStyleBoxHover.set("bg_color", colorColection["complementary_secondary"])
	buttonStyleBoxHover.set("border_color", colorColection["complementary_primary"])
	button_end_turn.add_theme_stylebox_override("hover", buttonStyleBoxHover)
	# Pressed
	button_end_turn.set("theme_override_colors/font_pressed_color", colorColection["complementary_font_color"])
	var buttonStyleBoxPressed: StyleBoxFlat = button_end_turn.get_theme_stylebox("pressed").duplicate()
	buttonStyleBoxPressed.set("bg_color", colorColection["complementary_secondary"])
	buttonStyleBoxPressed.set("border_color", colorColection["complementary_primary"])
	button_end_turn.add_theme_stylebox_override("pressed", buttonStyleBoxPressed)
	
	# Cards count label
	ui_cards_count_label.set("theme_override_colors/font_color", colorColection["primary"])
	var ui_cards_count_background_style_box: StyleBoxFlat = ui_cards_count_background_panel.get_theme_stylebox("panel").duplicate()
	ui_cards_count_background_style_box.set("bg_color", colorColection["font_color"])
	ui_cards_count_background_panel.add_theme_stylebox_override("panel", ui_cards_count_background_style_box)


func _handle_button_click():
	end_turn.emit()


func _cards_in_hand_ui_visible_on() -> void:
	cards_in_hand_ui_header_label.set_text(tr("LABEL_PLAYER_CARDS_IN_HAND") % player_name)
	cards_in_hand_ui_grid_container.set_custom_minimum_size(Vector2(0, 450 * ceili(cards_in_hand.size() / 5.0)))
	
	# Clean previous cards
	for element in cards_in_hand_ui_grid_container.get_children():
		cards_in_hand_ui_grid_container.remove_child(element)
		element.queue_free()
	# Add cards to grid
	for card in cards_in_hand:
		var ui_card = card.get_scene()
		ui_card.set_scale(Vector2(0.9, 0.9))
		ui_card.set_anchors_preset(LayoutPreset.PRESET_CENTER)
		var panel: Panel = Panel.new()
		panel.set_h_size_flags(SizeFlags.SIZE_SHRINK_CENTER ^ SizeFlags.SIZE_EXPAND)
		panel.set_v_size_flags(SizeFlags.SIZE_SHRINK_CENTER ^ SizeFlags.SIZE_EXPAND)
		panel.size_flags_horizontal
		panel.add_child(ui_card)
		cards_in_hand_ui_grid_container.add_child(panel)
		ui_card.flip_instant()
	
	if player_id == 1:
		cards_in_hand_ui_box_panel.set_pivot_offset(Vector2(0, 0))
		cards_in_hand_ui_box_panel.set_rotation_degrees(0)
	else:
		cards_in_hand_ui_box_panel.set_pivot_offset(cards_in_hand_ui_box_panel.get_size() / 2)
		cards_in_hand_ui_box_panel.set_rotation_degrees(180)
	cards_in_hand_ui.set_visible(true)


func _cards_in_hand_ui_visible_off() -> void:
	cards_in_hand_ui.set_visible(false)


func change_cards_count_label_value(from: int, to: int):
	var tween = create_tween()
	tween.tween_method(_change_cards_count_label_value, from, to, 0.25)


func _change_cards_count_label_value(value: int):
	ui_cards_count_label.set_text(str(value))

func disable_end_turn_button():
	button_end_turn.set_disabled(true)

func enable_end_turn_button():
	button_end_turn.set_disabled(false)

func calculate_score() -> void:
	var total_score : int = 0
	var einstein_max_value : int = 0
	var phoebe_max_value : int = 0
	var ciri_max_value : int = 0
	var legolas_max_value : int = 0
	var triss_max_value : int = 0
	var emma_max_value : int = 0
	var tauriel_max_value : int = 0
	var arya_max_value : int = 0
	var teddy_max_value : int = 0
	var kruemel_max_value : int = 0

	for card: Card in cards_in_hand:
		match card.type:
			1:
				if card.value > einstein_max_value:
					einstein_max_value = card.value
			2:
				if card.value > phoebe_max_value:
					phoebe_max_value = card.value
			3:
				if card.value > ciri_max_value:
					ciri_max_value = card.value
			4:
				if card.value > legolas_max_value:
					legolas_max_value = card.value
			5:
				if card.value > triss_max_value:
					triss_max_value = card.value
			6:
				if card.value > emma_max_value:
					emma_max_value = card.value
			7:
				if card.value > tauriel_max_value:
					tauriel_max_value = card.value
			8:
				if card.value > arya_max_value:
					arya_max_value = card.value
			9:
				if card.value > teddy_max_value:
					teddy_max_value = card.value
			10:
				if card.value > kruemel_max_value:
					kruemel_max_value = card.value
					
	total_score = total_score + einstein_max_value + phoebe_max_value + ciri_max_value + legolas_max_value + triss_max_value + emma_max_value + tauriel_max_value + arya_max_value + teddy_max_value + kruemel_max_value
	self.score = self.score + total_score
	score_value_label.set_text(str(self.score))

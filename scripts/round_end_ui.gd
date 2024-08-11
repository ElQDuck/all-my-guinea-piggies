extends CanvasLayer
signal start_next_round()

@export var player_1_ui: Panel
@export var player_2_ui: Panel
@export var button: Button
@export var ui_panel: Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	button.pressed.connect(_handle_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _handle_button_pressed():
	start_next_round.emit()
	ui_panel.set_pivot_offset(ui_panel.get_size() / 2)
	var scale_down_tween = create_tween()
	await scale_down_tween.tween_property(ui_panel, "scale", Vector2(0, 0), 0.25).from(Vector2(1, 1)).finished
	self.set_visible(false)


func make_visible(player_1_score: int, player_2_score: int):
	ui_panel.set_pivot_offset(ui_panel.get_size() / 2)
	self.set_visible(true)
	var scale_up_tween = create_tween()
	await scale_up_tween.tween_property(ui_panel, "scale", Vector2(1, 1), 0.25).from(Vector2(0, 0)).finished
	player_1_ui.update_score(player_1_score)
	player_2_ui.update_score(player_2_score)

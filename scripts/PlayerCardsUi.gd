extends CanvasLayer

@export var header_label: Label
@export var close_button: Button
@export var box_panel: Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	close_button.pressed.connect(visible_off)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func visible_on(player: Control) -> void:
	header_label.set_text(tr("LABEL_PLAYER_CARDS_IN_HAND") % player.player_name)
	if player.player_id == 1:
		box_panel.set_pivot_offset(Vector2(0, 0))
		box_panel.set_rotation_degrees(0)
	else:
		box_panel.set_pivot_offset(box_panel.get_size() / 2)
		box_panel.set_rotation_degrees(180)
	self.set_visible(true)


func visible_off() -> void:
	self.set_visible(false)

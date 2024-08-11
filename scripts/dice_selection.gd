extends CanvasLayer

@export var box_panel: Panel
@export var dice_select_panel: Panel
@export var lofty_button_1: TextureButton
@export var lofty_button_2: TextureButton
@export var lofty_button_3: TextureButton
@export var start_wheel_button: Button
@export var fortune_wheel: Control
var selected_lofty: int = 0
var oponent_cards_count: int = 0
var wheel_result: int = 0
signal fortune_wheel_spin_result(player_loses_cards_count: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	lofty_button_1.toggled.connect(_handle_lofty_selection.bind(1))
	lofty_button_2.toggled.connect(_handle_lofty_selection.bind(2))
	lofty_button_3.toggled.connect(_handle_lofty_selection.bind(3))
	start_wheel_button.pressed.connect(_handle_start_wheel_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Make the buttons invisible if oponent has less cards than possibly can be taken
	match oponent_cards_count:
		1:
			lofty_button_2.set_visible(false)
			lofty_button_3.set_visible(false)
		2:
			lofty_button_2.set_visible(true)
			lofty_button_3.set_visible(false)
		_:
			lofty_button_2.set_visible(true)
			lofty_button_3.set_visible(true)

	if !lofty_button_1.is_pressed() and !lofty_button_2.is_pressed() and !lofty_button_3.is_pressed():
		start_wheel_button.set_disabled(true)
	else:
		start_wheel_button.set_disabled(false)


func _handle_lofty_selection(toggled_on: bool, selection: int):
	if toggled_on:
		selected_lofty = selection


func _handle_start_wheel_button_pressed():
	# Make the dice buttons invisible
	dice_select_panel.set_visible(false)
	
	# Resize to 0 to scale up with tween to get a pop up effect
	fortune_wheel.set_scale(Vector2(0, 0))
	fortune_wheel.set_visible(true)
	
	# Scaling up
	var scale_up_tween = create_tween()
	await scale_up_tween.tween_property(fortune_wheel, "scale", Vector2(1, 1), 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).finished
	
	# Get random number for wheel result
	var random_num = randi() % 6 + 1
	
	# Spin the wheel
	await fortune_wheel.spin(random_num)
	#await get_tree().create_timer(5.5).timeout
	
	# Figure out how many cards the player will get from oponent depending on his selection and roll result
	match random_num:
		1:
			# -1 - One card of the player will be discarded
			wheel_result = -1
		2, 4:
			# 1 - The oponent loses one card to the active player if picked dice == 1
			match selected_lofty:
				1:
					wheel_result = 1
				2:
					wheel_result = 0
				3:
					wheel_result = 0
		3, 5:
			# 3 - The oponent loses:
			#	- 1 card to the active player if picked 1
			#	- 2 cards to the active player if picked 2
			#	- 3 cards to the active player if picked 3
			match selected_lofty:
				1:
					wheel_result = 1
				2:
					wheel_result = 2
				3:
					wheel_result = 3
		6:
			# 2 - The oponent loses:
			#	- 1 card to the active player if picked 1
			#	- 2 cards to the active player if picked 2
			match selected_lofty:
				1:
					wheel_result = 1
				2:
					wheel_result = 2
				3:
					wheel_result = 0
	
	# Scaling down
	var scale_down_tween = create_tween()
	scale_down_tween.tween_property(fortune_wheel, "scale", Vector2(0, 0), 0.7).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await scale_down_tween.finished
	
	# Reset this UI to the initial visibility
	dice_select_panel.set_visible(true)
	fortune_wheel.set_visible(false)
	self.set_visible(false)
	
	# Emit a signal with the wheel result
	fortune_wheel_spin_result.emit(wheel_result)


func make_visible(oponent_plyer_cards_count: int):
	oponent_cards_count = oponent_plyer_cards_count
	dice_select_panel.set_pivot_offset(dice_select_panel.get_size() / 2)
	self.set_visible(true)
	var scale_up_tween = create_tween()
	await scale_up_tween.tween_property(dice_select_panel, "scale", Vector2(1, 1), 0.5).from(Vector2(0, 0)).finished

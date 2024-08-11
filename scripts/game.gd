extends Node2D

@export var player_1: Control
@export var player_2: Control
@export var table: Control
@export var dice_selection_ui: CanvasLayer
@export var deck: TextureButton
@export var round_end_ui: CanvasLayer
@export var game_end_ui: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	player_1.end_turn.connect(_handle_player_end_turn_button.bind(player_1))
	player_1.profile_image_index = GlobalVars.player_1["selected_image_index"]
	player_1.player_name = GlobalVars.player_1["name"]
	player_1.colorColection = GlobalVars.player_1["color_combinations"]
	player_1.player_is_active = true
	
	player_2.end_turn.connect(_handle_player_end_turn_button.bind(player_2))
	player_2.profile_image_index = GlobalVars.player_2["selected_image_index"]
	player_2.player_name = GlobalVars.player_2["name"]
	player_2.colorColection = GlobalVars.player_2["color_combinations"]
	player_2.player_is_active = false
	
	player_1._update_ui()
	player_2._update_ui()
	
	table.add_cards_to_active_player.connect(_handle_add_cards_to_active_player)
	table.predator_detected.connect(_handle_predator_detected)
	dice_selection_ui.fortune_wheel_spin_result.connect(_handle_fortune_wheel_spin_result)
	
	deck.no_cards_in_deck.connect(_handle_no_cards_in_deck)
	deck.card_drawn_from_deck.connect(_handle_card_drawn_from_deck)
	
	round_end_ui.start_next_round.connect(_handle_start_next_round)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _handle_player_end_turn_button(player: Control):
	player.disable_end_turn_button()
	if table.drawn_cards_area.get_children().size() > 0:
		var old_cards_in_hand_count = player.cards_in_hand.size()
		player.cards_in_hand.append_array(table.cards_on_table)
		await table.move_cards_to_player(table.drawn_cards_area.get_children(), player)
		player.change_cards_count_label_value(old_cards_in_hand_count, player.cards_in_hand.size())
		table.clean_up_table()
	_switch_active_player()
	player.enable_end_turn_button()


func _handle_add_cards_to_active_player(cards: Array[Card]):
	var active_player: Control = _get_active_player()
	var old_cards_in_hand_count = active_player.cards_in_hand.size()
	active_player.cards_in_hand.append_array(cards)
	await table.move_cards_to_player(table.drawn_cards_area.get_children(), active_player)
	active_player.change_cards_count_label_value(old_cards_in_hand_count, active_player.cards_in_hand.size())
	table.clean_up_table()
	_switch_active_player()


func _handle_predator_detected():
	var oponent_cards_count = _get_oponent().cards_in_hand.size()
	if oponent_cards_count >= 1:
		dice_selection_ui.make_visible(oponent_cards_count)
		await dice_selection_ui.fortune_wheel_spin_result
	else:
		table.clean_up_table()
	_switch_active_player()


func _handle_fortune_wheel_spin_result(result: int):
	var active_player = _get_active_player()
	var oponent = _get_oponent()
	match result:
		-1:
			table.move_cards_from_player_to_center(_get_random_cards_from_player(active_player, 1), active_player, 0.25)
			await get_tree().create_timer(0.75).timeout
			var ui_card = table.drawn_cards_area.get_child(0)
			await ui_card.destroy_card()
			table.clean_up_table()
		1:
			var card = _get_random_cards_from_player(oponent, 1)
			table.move_cards_from_player_to_center(card, oponent, 0.25)
			await get_tree().create_timer(0.75).timeout
			await table.move_cards_to_player(table.drawn_cards_area.get_children(), active_player)
			_add_cards_to_player(active_player, card)
			table.clean_up_table()
		2:
			var cards = _get_random_cards_from_player(oponent, 2)
			table.move_cards_from_player_to_center(cards, oponent, 0.25)
			await get_tree().create_timer(0.75).timeout
			await table.move_cards_to_player(table.drawn_cards_area.get_children(), active_player)
			_add_cards_to_player(active_player, cards)
			table.clean_up_table()
		3:
			var cards = _get_random_cards_from_player(oponent, 3)
			table.move_cards_from_player_to_center(cards, oponent, 0.25)
			await get_tree().create_timer(0.75).timeout
			await table.move_cards_to_player(table.drawn_cards_area.get_children(), active_player)
			_add_cards_to_player(active_player, cards)
			table.clean_up_table()
		_:
			print(active_player.name + " wont get any cards because he is to greedy")


func _switch_active_player():
	if player_1.player_is_active:
		player_1.player_is_active = false
		player_2.player_is_active = true
	else:
		player_1.player_is_active = true
		player_2.player_is_active = false
	_get_active_player().disable_end_turn_button()


func _get_active_player() -> Control:
	if player_1.player_is_active:
		return player_1
	return player_2


func _get_oponent() -> Control:
	if player_1.player_is_active:
		return player_2
	return player_1


func _get_random_cards_from_player(player: Control, num_of_cards: int) -> Array[Card]:
	var player_hand_size = player.cards_in_hand.size()
	player.change_cards_count_label_value(player_hand_size, player_hand_size - num_of_cards)
	var cards: Array[Card] = []
	for n in range(num_of_cards):
		var random_card = player.cards_in_hand.pick_random()
		player.cards_in_hand.erase(random_card)
		cards.append(random_card)
	return cards


func _add_cards_to_player(player: Control, cards: Array[Card]) -> void:
	var player_hand_size = player.cards_in_hand.size()
	player.change_cards_count_label_value(player_hand_size, player_hand_size + cards.size())
	player.cards_in_hand.append_array(cards)


func _handle_card_drawn_from_deck(drawnCard: Card):
	# Enable the active players end turn button because now there are cards on the table
	_get_active_player().enable_end_turn_button()


func _handle_no_cards_in_deck() -> void:
	# First add the cards on the table to the player
	await _add_cards_to_player(_get_active_player(), table.cards_on_table)
	
	# Calculating the players score
	player_1.calculate_score()
	player_2.calculate_score()
	
	# If player score >= 77 -> the game ends
	if player_1.score >= 77 or player_2.score >= 77:
		game_end_ui.make_visible(player_1.score, player_2.score)
	# Otherwise a new round starts
	else:
		round_end_ui.make_visible(player_1.score, player_2.score)


func _handle_start_next_round():
	deck.reset_deck()
	table.clean_up_table()
	player_1.cards_in_hand.clear()
	player_1.ui_cards_count_label.set_text("0")
	player_2.cards_in_hand.clear()
	player_2.ui_cards_count_label.set_text("0")
	# Making the player with lower score to start player
	if player_1.score <= player_2.score:
		player_1.player_is_active = true
		player_2.player_is_active = false
	else:
		player_1.player_is_active = false
		player_2.player_is_active = true

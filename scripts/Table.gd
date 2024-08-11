extends Control
signal add_cards_to_active_player(cards: Array[Card])
signal predator_detected()

@export var deck: TextureButton
@export var drawn_cards_area: Control
@export var card_placement_area: Control
@export var played_card_scene: PackedScene
var cards_on_table: Array[Card] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	deck.card_drawn_from_deck.connect(_place_card_on_table)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _place_card_on_table(card: Card):
	# During the placement effect the deck button is deactivated.
	# This way the animation wont brake if double clicked.
	deck.set_disabled(true)
	## Add card to table
	var new_card: Card = Card.new(card.type, card.value)
	cards_on_table.append(new_card)
	var played_card: Panel = new_card.get_scene()
	# Add card to scene
	drawn_cards_area.add_child(played_card)
	# Animate card drawing
	var deck_position: Vector2 = get_object_global_center_position(deck)
	var cards_area_center_position: Vector2 = drawn_cards_area.get_global_position()
	var animation_speed = 0.5
	# Calculating the final position of all cards
	# 1. We get the field size to check on how many cards can be places
	var cards_area_size: Vector2 = card_placement_area.get_size()
	# 2. Then we get the size of the cards
	var card_size: Vector2 = played_card.get_card_size()
	# 3. Now we check how many cards can be placed in the are + we add a smal margin
	var position_offset: float = 20
	var offset_to_deck: float = position_offset
	var cards_count_fitting_in_area = floori(cards_area_size.x / (card_size.x + position_offset))
	var area_start_position: float = cards_area_center_position.x - (cards_area_size.x / 2)
	# 4. Now we know if we can just move the cards or have to overlap
	if cards_on_table.size() <= cards_count_fitting_in_area:
		# Cards fit in area
		position_offset = 20
	else:
		# Cards dont fit in are
		position_offset = -(((card_size.x * cards_on_table.size()) - cards_area_size.x + card_size.x) / cards_on_table.size())
	
	for n in range(cards_on_table.size()):
		# First card gets position with offset to Deck
		var card_final_position = 0
		if n == 0:
			card_final_position = Vector2(area_start_position + (card_size.x / 2) + offset_to_deck, cards_area_center_position.y)
		# The next cards get the position depending on first card
		else:
			card_final_position = Vector2(drawn_cards_area.get_child(0).global_position.x + ((card_size.x + position_offset) * n), cards_area_center_position.y)
		var current_card = drawn_cards_area.get_child(n)
		# last card gets also the draw from deck animation
		if n + 1 == cards_on_table.size():
			# First checking if the card is the predator
			if _check_predator(cards_on_table[n]):
				move_card_from_to(current_card, deck_position, DisplayServer.window_get_size() / 2, animation_speed)
				var size_tween = create_tween()
				await size_tween.tween_property(current_card, "scale", Vector2(1.25, 1.25), animation_speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
				await current_card.flip_card(animation_speed)
				await get_tree().create_timer(0.125).timeout
				# Destroying all drawn cards
				cards_on_table.clear()
				var cards_on_table_except_last = drawn_cards_area.get_children()
				cards_on_table_except_last.remove_at(n)
				for card_on_table in cards_on_table_except_last:
					card_on_table.destroy_card()
				await get_tree().create_timer(1.25).timeout
				predator_detected.emit()
				clean_up_table()
			else:
				# Then moving the card to the center and making it slightly bigger to have an effect of drawing
				move_card_from_to(current_card, deck_position, DisplayServer.window_get_size() / 2, animation_speed)
				var size_tween = create_tween()
				await size_tween.tween_property(current_card, "scale", Vector2(1.25, 1.25), animation_speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
				await current_card.flip_card(animation_speed)
				await get_tree().create_timer(0.125).timeout
				# then moving it to the needed position and making it the default size again
				move_card_to(current_card, card_final_position, animation_speed/2)
				var size_tween2 = create_tween()
				size_tween2.tween_property(current_card, "scale", Vector2(1, 1), animation_speed).set_ease(Tween.EASE_IN).from_current()
				# At the end rotate the card slightly to have an effect of drawn cards
				var rotation_tween = create_tween()
				rotation_tween.tween_property(current_card, "rotation", deg_to_rad(randi_range(-5, 5)), animation_speed)
		else:
			# moving already placed cards to the needed position
			move_card_to(current_card, card_final_position, animation_speed)
	# Wait until card is placed
	await get_tree().create_timer(animation_speed).timeout
	await _check_double_cards()
	# After everything is done, a new card can be drawn. The deck button gets activated again.
	deck.set_disabled(false)


func _check_double_cards():
	if cards_on_table.size() > 1:
		var last_card = cards_on_table.back()
		# Find double card types
		for i in range(cards_on_table.size() - 1):
			if cards_on_table[i].type == last_card.type:
				# Destroy all cards inbetween the double ones
				var cards_to_destroy: Array[Node] = []
				var cards_for_the_player: Array[Card] = []
				var cards_in_scene := drawn_cards_area.get_children()
				for drawn_card_index in range(cards_in_scene.size()):
					if drawn_card_index >= i:
						cards_to_destroy.append(cards_in_scene[drawn_card_index])
					else:
						cards_for_the_player.append(cards_on_table[drawn_card_index])
				await _destroy_cards(cards_to_destroy, 0.25)
				# Add rest to the player
				add_cards_to_active_player.emit(cards_for_the_player)
				# wait for signal to finish
				await get_tree().create_timer(1).timeout
				break

func _check_predator(newCard: Card) -> bool:
	if newCard.type == Card.PiggyType.Predator:
		return true
	return false



func move_card_from_to(card_in_scene: Panel, from: Vector2, to: Vector2, speed: float):
	var tween = create_tween()
	tween.tween_property(card_in_scene, "global_position", to, speed).from(from)


func move_card_to(card_in_scene: Panel, to: Vector2, speed: float):
	var tween = create_tween()
	tween.tween_property(card_in_scene, "global_position", to, speed).from_current()


func get_object_global_center_position(object) -> Vector2:
	var object_global_position: Vector2 = object.get_global_position()
	var object_size: Vector2 = object.get_size()
	var object_center_global_position: Vector2 = object_global_position + object_size / 2
	return object_center_global_position

func _move_cards_to_center(cards: Array[Node], speed: float):
	var display_area: Vector2 = DisplayServer.window_get_size() - DisplayServer.window_get_size() / 4
	var center: Vector2 = DisplayServer.window_get_size() / 2
	var overlap: int = 15 * cards.size()
	var card_size_x = cards[0].get_card_size().x
	var needed_card_area: int = cards.size() * (card_size_x - overlap)
	var card_placement_starting_point = DisplayServer.window_get_size().x / 2 - needed_card_area / 2 + card_size_x / 2
	for n in range(cards.size()):
		# Moving to center
		var final_card_position = Vector2(card_placement_starting_point + ((card_size_x - overlap) * n ), center.y)
		move_card_to(cards[n], final_card_position, speed)
		# Upsizing
		var size_tween := create_tween()
		size_tween.tween_property(cards[n], "scale", Vector2(1.3, 1.3), speed).from_current()
		# Rotating to normal
		var rotation_tween := create_tween()
		rotation_tween.tween_property(cards[n], "rotation", deg_to_rad(0), speed).from_current()
	# Waiting a bit
	await get_tree().create_timer(0.5).timeout
	
	
func _move_cards_to_player(cards: Array[Node], player_position: Vector2, speed: float):
	deck.set_disabled(true)
	await _move_cards_to_center(cards, speed)
	for n in range(cards.size()):
		# Moving to player
		move_card_to(cards[n], player_position, speed)
		# Sizing to zero
		var size_tween = create_tween()
		size_tween.tween_property(cards[n], "scale", Vector2(0, 0), speed).from_current()
	await get_tree().create_timer(speed).timeout
	deck.set_disabled(false)


func move_cards_from_player_to_center(cards: Array[Card], player: Control, speed: float):
	# spawn cards on player position
	for card in cards:
		var ui_card = card.get_scene()
		drawn_cards_area.add_child(ui_card)
		ui_card.flip_instant()
		ui_card.set_global_position(player.get_player_position())
		ui_card.set_scale(Vector2(0, 0))
	_move_cards_to_center(drawn_cards_area.get_children(), speed)

func _destroy_cards(cards: Array[Node], speed: float):
	await _move_cards_to_center(cards, speed)
	for card in cards:
		card.destroy_card()
	await get_tree().create_timer(1.25).timeout


func move_cards_to_player(cards: Array[Node], player: Control):
	await _move_cards_to_player(cards, player.get_player_position(), 0.25)


func clean_up_table():
	cards_on_table.clear()
	for ui_card_on_table in drawn_cards_area.get_children():
		drawn_cards_area.remove_child(ui_card_on_table)
		ui_card_on_table.queue_free()

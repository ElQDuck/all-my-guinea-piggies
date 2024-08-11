extends Button

@onready var Table = $"../../../../Table"
@onready var Player1 = $"../../../../Player1"
@onready var Player2 = $"../../../../Player2"
@onready var Dice1 = $"../HBoxContainer/1"
@onready var Dice2 = $"../HBoxContainer/2"
@onready var Dice3 = $"../HBoxContainer/3"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Dice1.is_pressed() and !Dice2.is_pressed() and !Dice3.is_pressed():
		self.disabled = true
	else:
		self.disabled = false
	
	# If the opposite player has less cards than 3 -> only make as much selections available as cards in hand
	# If the opposite player has no card this dialog should not apear.
	var inactivePlayer = Table.GetInactivePlayer()
	match inactivePlayer.CardsInHand.size():
		1:
			Dice2.disabled = true
			Dice3.disabled = true
		2:
			Dice3.disabled = true
		_:
			Dice2.disabled = false
			Dice3.disabled = false

# TODo: use button_group instead
func _on__toggled_1(toggled_on):
	if toggled_on:
		Dice2.set_pressed_no_signal(false)
		Dice3.set_pressed_no_signal(false)


func _on__toggled_2(toggled_on):
	if toggled_on:
		Dice1.set_pressed_no_signal(false)
		Dice3.set_pressed_no_signal(false)


func _on__toggled_3(toggled_on):
	if toggled_on:
		Dice1.set_pressed_no_signal(false)
		Dice2.set_pressed_no_signal(false)
		


func _on_self_pressed():
	if Dice1.button_pressed:
		RollDice(1)
	if Dice2.button_pressed:
		RollDice(2)
	if Dice3.button_pressed:
		RollDice(3)
	Table.SwitchPlaerTurn()
	Dice1.set_pressed_no_signal(false)
	Dice2.set_pressed_no_signal(false)
	Dice3.set_pressed_no_signal(false)
	$"../..".set_visible(false)

func RollDice(selectedDice: int):
	var activePlayer: Node2D = Table.GetActivePlayer()
	var inactivePlayer: Node2D = Table.GetInactivePlayer()
	# get a random number between 1 and 6
	var diceRollResult = randi() % 6 + 1
	match diceRollResult:
		1:
			# -1 - One card of the player will be discarded
			if activePlayer.CardsInHand.size() > 0:
				var discardedCard: Card = activePlayer.CardsInHand.pick_random()
				activePlayer.CardsInHand.erase(discardedCard)
		2, 4:
			# 1 - The oponent loses one card to the active player if picked dice == 1
			if selectedDice == 1:
				PickCardsFromOponent(1, activePlayer, inactivePlayer)
		3, 5:
			# 3 - The oponent loses:
			#	- 1 card to the active player if picked 1
			#	- 2 cards to the active player if picked 2
			#	- 3 cards to the active player if picked 3
			match selectedDice:
				1:
					PickCardsFromOponent(1, activePlayer, inactivePlayer)
				2:
					PickCardsFromOponent(2, activePlayer, inactivePlayer)
				3:
					PickCardsFromOponent(3, activePlayer, inactivePlayer)
		6:
			# 2 - The oponent loses:
			#	- 1 card to the active player if picked 1
			#	- 2 cards to the active player if picked 2
			match selectedDice:
				1:
					PickCardsFromOponent(1, activePlayer, inactivePlayer)
				2:
					PickCardsFromOponent(2, activePlayer, inactivePlayer)


func PickCardsFromOponent(numCards: int, activePlayer: Node2D, inactivePlayer: Node2D):
	match numCards:
		1:
			if inactivePlayer.CardsInHand.size() > 0:
				var exchangedCard: Card = inactivePlayer.CardsInHand.pick_random()
				inactivePlayer.CardsInHand.erase(exchangedCard)
				activePlayer.CardsInHand.append(exchangedCard)
		2:
			if inactivePlayer.CardsInHand.size() > 1:
				var exchangedCard1: Card = inactivePlayer.CardsInHand.pick_random()
				inactivePlayer.CardsInHand.erase(exchangedCard1)
				var exchangedCard2: Card = inactivePlayer.CardsInHand.pick_random()
				inactivePlayer.CardsInHand.erase(exchangedCard2)
				activePlayer.CardsInHand.append(exchangedCard1)
				activePlayer.CardsInHand.append(exchangedCard2)

		3:
			if inactivePlayer.CardsInHand.size() > 2:
				var exchangedCard1: Card = inactivePlayer.CardsInHand.pick_random()
				inactivePlayer.CardsInHand.erase(exchangedCard1)
				var exchangedCard2: Card = inactivePlayer.CardsInHand.pick_random()
				inactivePlayer.CardsInHand.erase(exchangedCard2)
				var exchangedCard3: Card = inactivePlayer.CardsInHand.pick_random()
				inactivePlayer.CardsInHand.erase(exchangedCard3)
				activePlayer.CardsInHand.append(exchangedCard1)
				activePlayer.CardsInHand.append(exchangedCard2)
				activePlayer.CardsInHand.append(exchangedCard3)

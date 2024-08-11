extends Node2D

@onready var Player1 = $"../Player1"
@onready var Player2 = $"../Player2"
@export var CardsOnTable: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _card_drawn_from_deck(drawnCard: Card):
	CardsOnTable.push_back(drawnCard)
	CheckPredator(drawnCard)
	CheckDoubleCards(drawnCard)

func CheckDoubleCards(newCard: Card):
	# Find double card types
	for i in range(CardsOnTable.size() - 1):
		if CardsOnTable[i].Type == newCard.Type:
			# Add left over cards to current player
			if Player1.Active:
				for j in range(i):
					Player1.CardsInHand.push_back(CardsOnTable[j])
			else:
				for j in range(i):
					Player2.CardsInHand.push_back(CardsOnTable[j])
			SwitchPlaerTurn()
			CleanupTable()
			break

func CheckPredator(newCard: Card):
	if newCard.Type == Card.PiggyType.Predator:
		CleanupTable()
		if Player1.Active and Player2.CardsInHand.size() > 0:
			$"../DiceSelectionUi/VBoxContainer/Label".text = "Player 1 Choose the number of cards you want to steal from Player 2."
			$"../DiceSelectionUi".set_visible(true)
		if Player1.Active and Player2.CardsInHand.size() == 0:
			SwitchPlaerTurn()
		if Player2.Active and Player1.CardsInHand.size() > 0:
			$"../DiceSelectionUi/VBoxContainer/Label".text = "Player 2 Choose the number of cards you want to steal from Player 1."
			$"../DiceSelectionUi".set_visible(true)
		if Player2.Active and Player1.CardsInHand.size() == 0:
			SwitchPlaerTurn()



func CleanupTable():
	CardsOnTable.clear()
	for uiCardOnTable in $"../TableUi/VBoxContainer/Cards/GridContainer".get_children():
		$"../TableUi/VBoxContainer/Cards/GridContainer".remove_child(uiCardOnTable)
		uiCardOnTable.queue_free()
	
func SwitchPlaerTurn():
	$"../Player1".Active = !$"../Player1".Active
	$"../Player2".Active = !$"../Player2".Active

func GetActivePlayer():
	if Player1.Active:
		return Player1
	return Player2

func GetInactivePlayer():
	if !Player1.Active:
		return Player1
	return Player2

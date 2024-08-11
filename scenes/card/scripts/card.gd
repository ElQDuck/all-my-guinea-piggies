## The Card object
class_name Card
extends Object

## The possible Types of guinea pigs
enum PiggyType { Predator = 0, Einstein = 1, Phoebe = 2, Ciri = 3, Legolas = 4, Triss = 5, Emma = 6, Tauriel = 7, Arya = 8, Teddy = 9, Kruemel = 10 }

## The GuineaPig Type
var type: int:
	get:
		return type
	set(new_type):
		type = clampi(new_type, 0, 10)

## The Card value.
## Possible values: 0 -> Predator; 1-4 Card Values
var value: int:
	get:
		return value
	set(new_value):
		value = clampi(new_value, 0, 4)

var played_card_scene: PackedScene = load("res://scenes/card/card.tscn")

func _init(type: int, value: int):
	self.type = clampi(type, 0, 10)
	self.value = clampi(value, 0, 4)


func get_scene() -> Panel:
	var played_card: Panel = played_card_scene.instantiate()
	var texturePathPreset := "res://scenes/card/visuals/%s%s.png"
	var texturePath = texturePathPreset % [PiggyType.keys()[type], value]
	played_card.front_texture = load(texturePath)
	played_card.card_value = value
	return played_card

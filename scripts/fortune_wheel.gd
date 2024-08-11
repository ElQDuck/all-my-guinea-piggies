extends Control

@export var wheel: Sprite2D
@export var arrow: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func spin(value: int):
	var final_degree: float = 0
	match value:
		1:
			# Predator
			final_degree = 360 * 7
		2:
			# 1 Lofty
			final_degree = 360 * 7 + 120
		3:
			# 3 Lofty
			final_degree = 360 * 7 + 60
		4:
			# 1 Lofty
			final_degree = 360 * 7 + 300
		5:
			# 3 Loftys
			final_degree = 360 * 7 + 240
		6:
			# 2 Loftys
			final_degree = 360 * 7 + 180
		_:
			# Predator
			final_degree = 360 * 7

	var tween = create_tween()
	await tween.tween_property(wheel, "rotation", deg_to_rad(final_degree), 5).from(deg_to_rad(0)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).finished

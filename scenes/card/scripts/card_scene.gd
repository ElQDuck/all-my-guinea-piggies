extends Panel

@export var card_view_port: SubViewportContainer
@export var back_texture: CompressedTexture2D
@export var front_texture: CompressedTexture2D
@export var displayed_card_image: TextureRect
@export var explosion_shader: GPUParticles2D
@export var glow_effect: SubViewportContainer
var card_value: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	displayed_card_image.set_texture(back_texture)
	var shader: ShaderMaterial = explosion_shader.get_process_material()
	shader.set("shader_parameter/sprite", front_texture)
	explosion_shader.set_process_material(shader)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func flip_card(flip_duration: float):
	var half_flip_dur = flip_duration / 2
	var card_rotation_tween_90 = create_tween()
	await card_rotation_tween_90.tween_property(card_view_port.material, "shader_parameter/y_rot", -90.0, half_flip_dur).finished
	displayed_card_image.set_texture(front_texture)
	var card_rotation_tween_180 = create_tween()
	await card_rotation_tween_180.tween_property(card_view_port.material, "shader_parameter/y_rot", -180.0, half_flip_dur).from_current().finished
	glow_on()


func flip_instant():
	displayed_card_image.set_texture(front_texture)
	glow_on()


func destroy_card():
	# Scale down to have an expolosion from inside effect
	glow_off()
	displayed_card_image.set_pivot_offset(displayed_card_image.get_size() / 2)
	var scale_tween = create_tween()
	scale_tween.tween_property(displayed_card_image, "scale", Vector2(0, 0), 0.125).from_current()
	await get_tree().create_timer(0.25).timeout
	explosion_shader.set_emitting(true)
	# waiting one second. This is the time of the explosion animation
	await get_tree().create_timer(1).timeout
	self.set_visible(false)


func get_card_size() -> Vector2:
	return card_view_port.get_size() / 2


func glow_on() -> void:
	if card_value == 4:
		glow_effect.set_visible(true)

func glow_off() -> void:
	glow_effect.set_visible(false)
	

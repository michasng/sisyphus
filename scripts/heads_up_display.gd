class_name HeadsUpDisplay
extends Control

@export var player: Player
@export var text_display_seconds := 3.0

@export var full_health_icon: Texture
@export var half_health_icon: Texture
@export var empty_health_icon: Texture

@export var full_stamina_icon: Texture
@export var half_stamina_icon: Texture
@export var empty_stamina_icon: Texture

@export var label_container: Control
@export var label: Label
@export var health_container: Container
@export var stamina_container: Container
@onready var type_sound_effect: SoundEffect = $TypeSoundEffect

var _typing_queue: String
var text: String:
	get:
		return label.text
	set(value):
		label.text = ""
		_typing_queue = value
		if value.is_empty():
			label_container.visible = false
		else:
			label_container.visible = true
			await get_tree().create_timer(text_display_seconds).timeout
			label_container.visible = false


func _ready() -> void:
	for _i in range(player.max_health):
		health_container.add_child(TextureRect.new())
	_update_health()

	for _i in range(player.max_stamina):
		stamina_container.add_child(TextureRect.new())
	_update_stamina()


func _process(_delta: float) -> void:
	_update_health()
	_update_stamina()
	
	if _typing_queue.length() > 0:
		label.text += _typing_queue[0]
		_typing_queue = _typing_queue.erase(0)
		type_sound_effect.resume()


func _update_health() -> void:
	_update_container(
		player.health,
		health_container,
		full_health_icon,
		half_health_icon,
		empty_health_icon,
	)


func _update_stamina() -> void:
	_update_container(
		player.stamina,
		stamina_container,
		full_stamina_icon,
		half_stamina_icon,
		empty_stamina_icon,
	)


func _update_container(
	value: float,
	container: Container,
	full_icon: Texture,
	half_icon: Texture,
	empty_icon: Texture,
) -> void:
	var full_icon_count: int = int(value)
	var half_icon_count: int = 1 if fmod(value, 1.0) >= 0.5 else 0
	
	for i in range(container.get_child_count()):
		var texture_rect = (container.get_child(i) as TextureRect)
		if i < full_icon_count:
			texture_rect.texture = full_icon
		elif i < full_icon_count + half_icon_count:
			texture_rect.texture = half_icon
		else:
			texture_rect.texture = empty_icon

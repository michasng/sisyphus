extends Control

@export var player: Player

@export var full_stamina_icon: Texture
@export var half_stamina_icon: Texture
@export var empty_stamina_icon: Texture

@onready var stamina_container: Container = $StaminaContainer


func _ready() -> void:
	for _i in range(player.max_stamina):
		stamina_container.add_child(TextureRect.new())

	_update_stamina()


func _process(_delta: float) -> void:
	_update_stamina()


func _update_stamina() -> void:
	var full_icon_count: int = int(player.stamina)
	var half_icon_count: int = 1 if fmod(player.stamina, 1.0) >= 0.5 else 0
	
	for i in range(stamina_container.get_child_count()):
		var texture_rect = (stamina_container.get_child(i) as TextureRect)
		if i < full_icon_count:
			texture_rect.texture = full_stamina_icon
		elif i < full_icon_count + half_icon_count:
			texture_rect.texture = half_stamina_icon
		else:
			texture_rect.texture = empty_stamina_icon

class_name Gate
extends StaticBody2D

@export var required_buttons_pressed_count := 1

@onready var open_sound_effect: SoundEffect = $OpenSoundEffect
var _buttons_pressed_count := 0

signal opened


func _on_button_is_pressed_changed(is_pressed: bool) -> void:
	if is_pressed:
		_buttons_pressed_count += 1
	else:
		_buttons_pressed_count -= 1
	
	if _buttons_pressed_count >= required_buttons_pressed_count:
		# gate "opens" by effectively disappearing
		visible = false
		collision_layer = 0
		collision_mask = 0
		# the node is not freed, because then the sound effect wouldn't play
		open_sound_effect.play()
		opened.emit()

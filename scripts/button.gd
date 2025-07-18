class_name ButtonTile
extends Area2D

@export var can_be_released := false

@onready var _up_sprite: Sprite2D = $UpSprite2D
@onready var _down_sprite: Sprite2D = $DownSprite2D
@onready var _press_sound_effect: SoundEffect = $PressSoundEffect
@onready var _release_sound_effect: SoundEffect = $ReleaseSoundEffect

var is_pressed := false:
	set(value):
		if value == is_pressed:
			return
		is_pressed = value
		_up_sprite.visible = not is_pressed
		_down_sprite.visible = is_pressed
		if is_pressed:
			_press_sound_effect.play()
		else:
			_release_sound_effect.play()
		is_pressed_changed.emit(is_pressed)

signal is_pressed_changed(is_pressed: bool)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(_body: Node2D) -> void:
	is_pressed = true


func _on_body_exited(_body: Node2D) -> void:
	if can_be_released:
		is_pressed = false


func on_gate_opened() -> void:
	can_be_released = false
	is_pressed = true

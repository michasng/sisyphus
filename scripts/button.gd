class_name ButtonTile
extends Area2D

@onready var _up_sprite: Sprite2D = $UpSprite2D
@onready var _down_sprite: Sprite2D = $DownSprite2D
@onready var _press_sound_effect: SoundEffect = $PressSoundEffect

var is_pressed := false:
	set(value):
		is_pressed = value
		_up_sprite.visible = not is_pressed
		_down_sprite.visible = is_pressed
		if is_pressed:
			_press_sound_effect.play()
			pressed.emit()

signal pressed


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node2D) -> void:
	if not is_pressed:
		is_pressed = true

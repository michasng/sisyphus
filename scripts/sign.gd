class_name Sign
extends StaticBody2D

@export var text: String
@export var is_on_dirt := false

@onready var _sprite_on_grass: Sprite2D = $SpriteOnGrass
@onready var _sprite_on_dirt: Sprite2D = $SpriteOnDirt
@onready var _read_hint: Node = $ColorRect

signal read(text)
signal stop_reading(text)


func _ready() -> void:
	_sprite_on_grass.visible = not is_on_dirt
	_sprite_on_dirt.visible = is_on_dirt


func _input(event: InputEvent) -> void:
	if not _read_hint.visible:
		return

	if event.is_action("up") or event.is_action("down") or event.is_action("left") or event.is_action("right"):
		return

	if event is InputEventKey or InputEventJoypadButton and event.is_pressed():
		_read_hint.visible = false
		read.emit(text)


func _on_read_area_2d_body_entered(_body: Node2D) -> void:
	_read_hint.visible = true


func _on_read_area_2d_body_exited(_body: Node2D) -> void:
	_read_hint.visible = false
	stop_reading.emit(text)

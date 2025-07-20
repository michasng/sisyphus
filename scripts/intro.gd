class_name Intro
extends Node2D

@onready var _skip_label: Label = $ColorRect/SkipLabel


func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	_skip_label.visible = true


func _input(event: InputEvent) -> void:
	if _skip_label.visible and event is InputEventKey or InputEventJoypadButton and event.is_pressed():
		(get_parent() as Root).start_game()

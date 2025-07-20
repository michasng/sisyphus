class_name Intro
extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var can_skip := false


func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	can_skip = true
	animation_player.play("label_flash")


func _input(event: InputEvent) -> void:
	if can_skip and event is InputEventKey or InputEventJoypadButton and event.is_pressed():
		(get_parent() as Root).start_game()

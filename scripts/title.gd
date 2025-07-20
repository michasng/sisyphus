class_name Title
extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	animated_sprite.play()


func _input(event: InputEvent) -> void:
	if event is InputEventKey or InputEventJoypadButton and event.is_pressed():
		get_tree().change_scene_to_file("res://scenes/game.tscn")

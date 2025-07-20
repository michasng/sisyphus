class_name Title
extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animated_sprite.play()
	await get_tree().create_timer(3.0).timeout
	animation_player.play("label_flash")


func _input(event: InputEvent) -> void:
	if event is InputEventKey or InputEventJoypadButton and event.is_pressed():
		(get_parent() as Root).start_game()

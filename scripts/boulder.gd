class_name Boulder
extends CharacterBody2D


@onready var push_velocity_pixels_per_second := 0.5 * Game.TILE_SIZE_PIXELS

var is_pushed := false


func _physics_process(_delta: float) -> void:
	if is_pushed:
		velocity = Vector2(0, -push_velocity_pixels_per_second)
	else:
		velocity = Vector2.ZERO
		return

	move_and_slide()


func _on_player_moved(_velocity: Vector2, is_pushing: bool) -> void:
	is_pushed = is_pushing

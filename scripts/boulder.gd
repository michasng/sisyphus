class_name Boulder
extends StaticBody2D


@onready var push_velocity_pixels_per_second := 0.5 * Game.TILE_SIZE_PIXELS

var is_pushed := false
var velocity_pixels_per_second: Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if is_pushed:
		velocity_pixels_per_second = Vector2(0, -push_velocity_pixels_per_second)
	else:
		velocity_pixels_per_second = Vector2.ZERO

	move_and_collide(velocity_pixels_per_second * delta)


func _on_player_moved(_velocity: Vector2, is_pushing: bool) -> void:
	is_pushed = is_pushing

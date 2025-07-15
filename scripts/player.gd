class_name Player
extends CharacterBody2D

@onready var walk_velocity_pixels_per_second := 3.0 * Game.TILE_SIZE_PIXELS

signal moved(velocity: Vector2)


func _physics_process(_delta: float) -> void:
	_handle_walking()
	moved.emit(velocity)
	move_and_slide()


func _handle_walking() -> void:
	var input_direction := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down"),
	).normalized()
	
	if not input_direction:
		velocity = Vector2.ZERO
		return

	velocity = input_direction * walk_velocity_pixels_per_second

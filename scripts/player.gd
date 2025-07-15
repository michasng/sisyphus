class_name Player
extends CharacterBody2D

@onready var walk_velocity_pixels_per_second := 3.0 * Game.TILE_SIZE_PIXELS

@onready var boulder_ray_cast: RayCast2D = $BoulderRayCast2D

signal moved(velocity: Vector2, is_pushing: bool)


func _physics_process(_delta: float) -> void:
	var input_direction := Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down"),
	).normalized()

	velocity = input_direction * walk_velocity_pixels_per_second

	move_and_slide()

	var is_pushing = input_direction.angle() == Vector2.UP.angle() and boulder_ray_cast.is_colliding()
	moved.emit(velocity, is_pushing)

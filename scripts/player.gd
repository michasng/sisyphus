class_name Player
extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	PUSH,
	REST,
}

@export var state := State.IDLE

@export var walk_velocity_pixels_per_second := 3.0 * Game.TILE_SIZE_PIXELS
@export var max_stamina := 3
@export var stamina_recharge_per_second := 0.5
@export var stamina_consumption_per_second := 0.5

@onready var boulder_ray_cast: RayCast2D = $BoulderRayCast2D

var stamina: float = max_stamina:
	set(value):
		stamina = value


func _physics_process(delta: float) -> void:
	# mind the order: transition states before handling physics
	_transition_states()
	_handle_physics(delta)


func _transition_states() -> void:
	if stamina <= 0 or (state == State.REST and stamina < max_stamina):
		state = State.REST
		return

	var input_direction = _get_input_direction()
	if input_direction.angle() == Vector2.UP.angle() and boulder_ray_cast.is_colliding():
		state = State.PUSH
	elif input_direction:
		state = State.WALK
	else:
		state = State.IDLE


func _handle_physics(delta: float) -> void:
	if state not in [State.IDLE, State.REST]:
		velocity = _get_input_direction() * walk_velocity_pixels_per_second
		move_and_slide()

	if state == State.PUSH:
		stamina = move_toward(stamina, 0, stamina_consumption_per_second * delta)
	else:
		stamina = move_toward(stamina, max_stamina, stamina_recharge_per_second * delta)


func _get_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down"),
	).normalized()

class_name Player
extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	SPRINT,
	PUSH,
	REST,
}

@export var state := State.IDLE

@export var walk_velocity_pixels_per_second := 3.0 * Game.TILE_SIZE_PIXELS
@export var sprint_velocity_pixels_per_second := 4.5 * Game.TILE_SIZE_PIXELS
@export var max_stamina := 3
@export var stamina_recharge_per_second := 0.5
@export var push_stamina_consumption_per_second := 0.5
@export var sprint_stamina_consumption_per_second := 0.5

var stamina: float = max_stamina:
	set(value):
		stamina = value

@onready var _boulder_ray_cast: RayCast2D = $BoulderRayCast2D
var blocks_boulder: bool:
	get:
		return _boulder_ray_cast.is_colliding()


func _physics_process(delta: float) -> void:
	# mind the order: transition states before handling physics
	_transition_states()
	_handle_physics(delta)
	_handle_stamina(delta)


func _transition_states() -> void:
	if stamina <= 0 or (state == State.REST and stamina < max_stamina):
		state = State.REST
		return

	var input_direction = _get_input_direction()
	if input_direction.angle() == Vector2.UP.angle() and blocks_boulder:
		state = State.PUSH
	elif input_direction:
		if Input.is_action_pressed("sprint"):
			state = State.SPRINT
		else:
			state = State.WALK
	else:
		state = State.IDLE


func _handle_physics(_delta: float) -> void:
	if state not in [State.IDLE, State.REST]:
		if state == State.SPRINT:
			velocity = _get_input_direction() * sprint_velocity_pixels_per_second
		else:
			velocity = _get_input_direction() * walk_velocity_pixels_per_second
		move_and_slide()


func _handle_stamina(delta: float) -> void:
	if state == State.SPRINT:
		stamina = move_toward(stamina, 0, sprint_stamina_consumption_per_second * delta)
	elif state == State.PUSH:
		stamina = move_toward(stamina, 0, push_stamina_consumption_per_second * delta)
	else:
		stamina = move_toward(stamina, max_stamina, stamina_recharge_per_second * delta)


func _get_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down"),
	).normalized()

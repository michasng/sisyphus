class_name Player
extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	SPRINT,
	PUSH,
	REST,
}

@export var state := State.IDLE:
	set(value):
		if value != state: # state changed
			if value == State.REST:
				_rest_sound_effect.resume()
			if state == State.REST:
				_rested_sound_effect.resume()
		state = value

@export var walk_velocity_pixels_per_second := 3.0 * Game.TILE_SIZE_PIXELS
@export var sprint_velocity_pixels_per_second := 4.5 * Game.TILE_SIZE_PIXELS
@export var max_health := 3
@export var max_stamina := 3
@export var stamina_recharge_per_second := 1.0
@export var push_stamina_consumption_per_second := 0.5
@export var sprint_stamina_consumption_per_second := 0.5

var health: float = max_health
var stamina: float = max_stamina

@onready var _up_boulder_ray_cast: RayCast2D = $UpBoulderRayCast
@onready var _left_boulder_ray_cast: RayCast2D = $LeftBoulderRayCast
@onready var _right_boulder_ray_cast: RayCast2D = $RightBoulderRayCast

@onready var _step_sound_effect: SoundEffect = $StepSoundEffect
@onready var _rest_sound_effect: SoundEffect = $RestSoundEffect
@onready var _rested_sound_effect: SoundEffect = $RestedSoundEffect


func _physics_process(delta: float) -> void:
	# mind the order: transition states before handling physics
	_transition_states()
	_handle_physics(delta)
	_handle_stamina(delta)


func _transition_states() -> void:
	if stamina <= 0 or (state == State.REST and stamina < max_stamina):
		state = State.REST
		return

	var input_direction = get_input_direction()
	if input_direction:
		if input_direction.angle() == Vector2.UP.angle() and _up_boulder_ray_cast.is_colliding() or \
			input_direction.angle() == Vector2.LEFT.angle() and _left_boulder_ray_cast.is_colliding() or \
			input_direction.angle() == Vector2.RIGHT.angle() and _right_boulder_ray_cast.is_colliding():
			state = State.PUSH
		elif Input.is_action_pressed("sprint"):
			state = State.SPRINT
		else:
			state = State.WALK
	else:
		state = State.IDLE


func _handle_physics(_delta: float) -> void:
	if state not in [State.IDLE, State.REST]:
		if state == State.SPRINT:
			velocity = get_input_direction() * sprint_velocity_pixels_per_second
		else:
			velocity = get_input_direction() * walk_velocity_pixels_per_second
		move_and_slide()

		if velocity.length() > 0.0:
			# time between steps calculated based on FPS and sound effect duration
			_step_sound_effect.pause_time_seconds = 0.087 if state == State.SPRINT else 0.17
			_step_sound_effect.resume()


func _handle_stamina(delta: float) -> void:
	if state == State.SPRINT:
		stamina = move_toward(stamina, 0, sprint_stamina_consumption_per_second * delta)
	elif state == State.PUSH:
		stamina = move_toward(stamina, 0, push_stamina_consumption_per_second * delta)
	else:
		stamina = move_toward(stamina, max_stamina, stamina_recharge_per_second * delta)


func get_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down"),
	).normalized()

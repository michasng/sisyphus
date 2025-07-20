class_name Boulder
extends CharacterBody2D

enum State {
	IDLE,
	PUSH,
	ROLL,
}

@export var player: Player

var state_timer_seconds := 0.0
@export var state := State.IDLE:
	set(value):
		var previous_state = state
		state = value
		state_timer_seconds = 0.0
		state_changed.emit(previous_state, state)
		if _move_particles: # not assigned when exported state is set
			_move_particles.emitting = state != State.IDLE

@export var max_push_velocity_pixels_per_second := 1.5 * Game.TILE_SIZE_PIXELS
# nearly as fast as the player can walk
@export var max_roll_velocity_pixels_per_second := 3.5 * Game.TILE_SIZE_PIXELS
@export var idle_to_roll_duration_seconds := 2.0
@export var acceleration_seconds := 5.0

@onready var acceleration_pixels_per_second_squared := max_roll_velocity_pixels_per_second / acceleration_seconds
@onready var _no_roll_area: Area2D = $NoRollArea2D
@onready var _move_particles: GPUParticles2D = $MoveParticles
@onready var _move_sound_effect: SoundEffect = $MoveSoundEffect
@onready var stop_sound_effect: SoundEffect = $StopSoundEffect

signal state_changed(previous_state: State, current_state: State)


func _physics_process(delta: float) -> void:
	# mind the order: transition states before handling physics
	_transition_states()
	_handle_physics(delta)
	state_timer_seconds += delta


func _transition_states() -> void:
	if player.state == Player.State.PUSH:
		state = State.PUSH
		return
	
	var should_stop_roll = _no_roll_area.get_overlapping_bodies().any(func(body): return body != self)
	match state:
		State.IDLE:
			if should_stop_roll:
				return
			if state_timer_seconds >= idle_to_roll_duration_seconds:
				state = State.ROLL
		State.ROLL:
			if should_stop_roll:
				state = State.IDLE
		State.PUSH:
			state = State.IDLE


func _handle_physics(delta: float) -> void:
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.PUSH:
			var input_direction = player.get_input_direction()
			velocity = Vector2(
				move_toward(
					velocity.x,
					input_direction.x * max_push_velocity_pixels_per_second,
					acceleration_pixels_per_second_squared * delta,
				),
				move_toward(
					velocity.y,
					input_direction.y * max_push_velocity_pixels_per_second,
					acceleration_pixels_per_second_squared * delta,
				)
			)
		State.ROLL:
			velocity = Vector2(
				0,
				move_toward(
					velocity.y,
					max_roll_velocity_pixels_per_second,
					acceleration_pixels_per_second_squared * delta
				)
			)

	# move_and_slide had this body being pushed by accident.
	# Unlike move_and_slide, delta needs to be applied
	# and velocity needs to be updated manually.
	# The boulder can still be nudged slightly,
	# but only testing for collisions and setting velocity to ZERO on collision
	# caused the boulder to get stuck on corners, due to its spherical shape.
	var position_before = position
	var collision = move_and_collide(velocity * delta)
	velocity = (position - position_before) / delta

	if collision != null:
		state = State.PUSH

	if velocity.length() > Game.TILE_SIZE_PIXELS * 0.2:
		var velocity_fraction = velocity.length() / max_roll_velocity_pixels_per_second
		_move_sound_effect.volume_linear = lerpf(0.3, 1.0, velocity_fraction)
		_move_sound_effect.resume()

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

@export var max_push_velocity_pixels_per_second := 1.5 * Game.TILE_SIZE_PIXELS
# nearly as fast as the player can walk
@export var max_roll_velocity_pixels_per_second := 3.5 * Game.TILE_SIZE_PIXELS
@export var idle_to_roll_duration_seconds := 1.0
@export var acceleration_seconds := 5.0
@export var stop_roll_y := 0.0

@onready var acceleration_pixels_per_second_squared := max_roll_velocity_pixels_per_second / acceleration_seconds
@onready var move_sound_effect: SoundEffect = $MoveSoundEffect
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
	
	var should_stop_roll := position.y >= stop_roll_y
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
			velocity = Vector2(
				0,
				move_toward(
					velocity.y,
					-max_push_velocity_pixels_per_second,
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

	# Only test for collisions instead of letting Godot handle them,
	# or else other bodies can push this one.
	# Unlike move_and_slide, delta needs to be applied
	# and velocity needs to be updated manually.
	var collided = move_and_collide(velocity * delta, true) != null
	if collided:
		state = State.PUSH
		velocity = Vector2.ZERO
	else:
		position += velocity * delta

	if velocity.length() > Game.TILE_SIZE_PIXELS * 0.2:
		var velocity_fraction = velocity.length() / max_roll_velocity_pixels_per_second
		move_sound_effect.volume_linear = lerpf(0.3, 1.0, velocity_fraction)
		move_sound_effect.resume()

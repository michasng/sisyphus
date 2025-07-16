class_name Boulder
extends StaticBody2D

enum State {
	IDLE,
	PUSH,
	ROLL,
}

var state_timer_seconds := 0.0
@export var state := State.IDLE:
	set(value):
		state = value
		state_timer_seconds = 0.0
# in pixels per second, consistent with CharacterBody2D.velocity
@export var velocity := Vector2.ZERO
@export var player: Player

@onready var push_velocity_pixels_per_second := 0.5 * Game.TILE_SIZE_PIXELS
# nearly as fast as the player can walk
@onready var max_roll_velocity_pixels_per_second := 3.5 * Game.TILE_SIZE_PIXELS
@onready var roll_acceleration_pixels_per_second_squared := 5.0
@onready var idle_to_roll_duration_seconds := 1.0
@onready var stop_roll_y := 0.0


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
			velocity = Vector2(0, -push_velocity_pixels_per_second)
		State.ROLL:
			velocity = Vector2(
				0,
				move_toward(
					velocity.y,
					max_roll_velocity_pixels_per_second,
					roll_acceleration_pixels_per_second_squared * delta
				)
			)

	var position_before = position
	# unlike move_and_slide, delta is not applied internally
	move_and_collide(velocity * delta)
	# move_and_slide would usually also update the velocity
	# depending on how far the character actually moved
	velocity = (position - position_before) / delta

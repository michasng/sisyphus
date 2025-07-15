class_name Boulder
extends StaticBody2D


@onready var push_velocity_pixels_per_second := 0.5 * Game.TILE_SIZE_PIXELS
# nearly as fast as the player can walk
@onready var max_roll_velocity_pixels_per_second := 2.95 * Game.TILE_SIZE_PIXELS
@onready var roll_acceleration_pixels_per_second_squared := 2.0
@onready var idle_to_roll_duration_seconds := 1.0

# in pixels per second, consistent with CharacterBody2D.velocity
var velocity := Vector2.ZERO

enum State {
	IDLE,
	PUSHED,
	ROLLING,
}

var state_timer_seconds := 0.0
var state := State.IDLE:
	set(value):
		state = value
		state_timer_seconds = 0.0


func _physics_process(delta: float) -> void:
	# mind the order: transition states before handling physics
	if state == State.IDLE and state_timer_seconds >= idle_to_roll_duration_seconds:
		state = State.ROLLING
	
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			
		State.PUSHED:
			velocity = Vector2(0, -push_velocity_pixels_per_second)
		State.ROLLING:
			velocity = Vector2(
				0,
				move_toward(
					velocity.y,
					max_roll_velocity_pixels_per_second,
					roll_acceleration_pixels_per_second_squared * delta
				)
			)

	# unlike move_and_slide, delta is not applied internally
	move_and_collide(velocity * delta)
	
	state_timer_seconds += delta


func _on_player_moved(_velocity: Vector2, is_pushing: bool) -> void:
	if is_pushing:
		state = State.PUSHED
	elif state == State.PUSHED:
		state = State.IDLE

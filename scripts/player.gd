class_name Player
extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	SPRINT,
	PUSH,
	REST,
	PUNCH,
}

var state_timer_seconds := 0.0
@export var state := State.IDLE:
	set(value):
		if value != state: # state changed
			state_timer_seconds = 0.0
			if value == State.REST:
				_rest_sound_effect.resume()
			if state == State.REST:
				_rested_sound_effect.resume()
			if value == State.PUNCH:
				_punch_sound_effect.resume()
				_hit_box_by_direction[view_direction].monitorable = true
				_hit_box_by_direction[view_direction].visible = true
			if state == State.PUNCH:
				# disable all, because the view_dirction might have changed
				for direction in _hit_box_by_direction:
					_hit_box_by_direction[direction].monitorable = false
					_hit_box_by_direction[direction].visible = false
		state = value

@export var view_direction: Vector2i = Vector2i.DOWN
@export var walk_velocity_pixels_per_second := 3.0 * Game.TILE_SIZE_PIXELS
@export var sprint_velocity_pixels_per_second := 4.5 * Game.TILE_SIZE_PIXELS
@export var max_health := 3
@export var max_stamina := 3
@export var stamina_recharge_per_second := 1.0
@export var push_stamina_consumption_per_second := 0.5
@export var sprint_stamina_consumption_per_second := 0.5
@export var punch_seconds := 0.5

var health: float = max_health
var stamina: float = max_stamina

@export var hurt_flash_active: bool:
	get:
		return (self.material as ShaderMaterial).get_shader_parameter("active")
	set(value):
		(self.material as ShaderMaterial).set_shader_parameter("active", value)

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

@onready var _hit_box_by_direction: Dictionary[Vector2i, Area2D] = {
	Vector2i.UP: $Punch/UpHitBox,
	Vector2i.DOWN: $Punch/DownHitBox,
	Vector2i.LEFT: $Punch/LeftHitBox,
	Vector2i.RIGHT: $Punch/RightHitBox,
}

@onready var _up_boulder_ray_cast: RayCast2D = $Push/UpBoulderRayCast
@onready var _left_boulder_ray_cast: RayCast2D = $Push/LeftBoulderRayCast
@onready var _right_boulder_ray_cast: RayCast2D = $Push/RightBoulderRayCast

@onready var _step_sound_effect: SoundEffect = $SoundEffects/Step
@onready var _rest_sound_effect: SoundEffect = $SoundEffects/Rest
@onready var _rested_sound_effect: SoundEffect = $SoundEffects/Rested
@onready var _hurt_sound_effect: SoundEffect = $SoundEffects/Hurt
@onready var _punch_sound_effect: SoundEffect = $SoundEffects/Punch

signal hurt


func _physics_process(delta: float) -> void:
	# mind the order: transition states before handling physics
	_transition_states()
	_handle_physics(delta)
	_handle_stamina(delta)
	state_timer_seconds += delta


func _transition_states() -> void:
	if stamina <= 0 or (state == State.REST and stamina < max_stamina):
		view_direction = Vector2i.DOWN
		state = State.REST
		return

	if Input.is_action_just_pressed("punch") or \
	 	(state == State.PUNCH and state_timer_seconds < punch_seconds):
		state = State.PUNCH
		return

	var input_direction = get_input_direction()
	if input_direction:
		view_direction = to_view_direction(input_direction)
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
	if state not in [State.IDLE, State.REST, State.PUNCH]:
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


func to_view_direction(direction: Vector2) -> Vector2i:
	if direction.y < 0:
		return Vector2i.UP
	if direction.y > 0:
		return Vector2i.DOWN
	if direction.x < 0:
		return Vector2i.LEFT
	if direction.x > 0:
		return Vector2i.RIGHT
	# sensible default, but should never get here
	return Vector2i.DOWN


func get_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down"),
	).normalized()


func _hurt(damage: float) -> void:
	health -= damage
	if health <= 0:
		# call_deferred, because collision objects mustn't be removed in physics frame
		(get_tree().root.get_child(0) as Root).call_deferred("restart_game")
		return

	_hurt_sound_effect.resume()
	hurt.emit()

	# Must call_deferred, because the animation disables hurt_box.monitoring,
	# which is locked in this signal callback.
	_animation_player.call_deferred("play", "hurt")


func _on_hurt_box_body_entered(_body: Node2D) -> void:
	_hurt(0.5)

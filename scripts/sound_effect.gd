class_name SoundEffect
extends AudioStreamPlayer2D

@export var min_pitch_scale := 0.7
@export var max_pitch_scale := 2.0
@export var pause_time_seconds := 0.0

var _rng := RandomNumberGenerator.new()

var _pause_timer_seconds := 0.0


func _process(delta: float) -> void:
	if playing:
		_pause_timer_seconds = 0
	else:
		_pause_timer_seconds += delta


func resume() -> void:
	if not playing and _pause_timer_seconds >= pause_time_seconds:
		pitch_scale = random_pitch_scale()
		play()


func random_pitch_scale() -> float:
	return _rng.randf_range(min_pitch_scale, max_pitch_scale)

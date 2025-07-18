class_name SoundEffect
extends AudioStreamPlayer2D

@export var min_pitch_scale := 0.7
@export var max_pitch_scale := 2.0

var _rng := RandomNumberGenerator.new()


func resume() -> void:
	if not playing:
		pitch_scale = random_pitch_scale()
		play()


func random_pitch_scale() -> float:
	return _rng.randf_range(min_pitch_scale, max_pitch_scale)

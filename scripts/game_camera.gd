class_name GameCamera
extends Camera2D

@export var target: Node2D

var rng := RandomNumberGenerator.new()
var shake_strength_pixels := 0.0
var fade_out_shake_strength_pixels_per_second := 0.0


func _process(delta: float) -> void:
	if target.position.y <= 0:
		position.y = target.position.y

	if shake_strength_pixels == 0:
		offset = Vector2.ZERO
	else:
		offset = Vector2(
			rng.randf_range(-shake_strength_pixels, shake_strength_pixels),
			rng.randf_range(-shake_strength_pixels, shake_strength_pixels),
		)
		shake_strength_pixels = move_toward(shake_strength_pixels, 0, fade_out_shake_strength_pixels_per_second * delta)


func shake(strength_pixels: float, fade_out_seconds: float = 0.5) -> void:
	shake_strength_pixels = strength_pixels
	if fade_out_seconds > 0:
		fade_out_shake_strength_pixels_per_second = strength_pixels / fade_out_seconds
	else:
		# immediate fade-out in a single frame
		fade_out_shake_strength_pixels_per_second = strength_pixels * Engine.get_frames_per_second()

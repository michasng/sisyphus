class_name PlayerAnimatedSprite2D
extends AnimatedSprite2D


func _on_player_moved(velocity: Vector2, is_pushing: bool) -> void:
	if is_pushing:
		play("push_up")
		flip_h = false
		return

	if velocity == Vector2.ZERO:
		stop()
		# Stop on the last frame, because I've made the last frames look idle
		# so the first frame is always in movement.
		# Otherwise the player appears to slide while an animation starts.
		frame = sprite_frames.get_frame_count(animation) - 1
		return

	flip_h = velocity.y == 0 and velocity.x > 0

	if velocity.y < 0:
		play("walk_up")
	elif velocity.y > 0:
		play("walk_down")
	elif velocity.x < 0:
		play("walk_left")
	elif velocity.x > 0:
		play("walk_left")

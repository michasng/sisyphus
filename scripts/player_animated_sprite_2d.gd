class_name PlayerAnimatedSprite2D
extends AnimatedSprite2D


func _on_player_moved(velocity: Vector2) -> void:
	if velocity.y < 0:
		play("walk_up")
		flip_h = false
	elif velocity.y > 0:
		play("walk_down")
		flip_h = false
	elif velocity.x < 0:
		play("walk_left")
		flip_h = false
	elif velocity.x > 0:
		play("walk_left")
		flip_h = true
	else:
		stop()

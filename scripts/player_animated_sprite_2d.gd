class_name PlayerAnimatedSprite2D
extends AnimatedSprite2D

@export var player: Player


func _process(_delta: float) -> void:
	match player.state:
		Player.State.IDLE:
			if animation == "rest":
				animation = "walk_down"
			stop()
			# Stop on the last frame, because I've made the last frames look idle
			# so the first frame is always in movement.
			# Otherwise the player appears to slide while an animation starts.
			frame = sprite_frames.get_frame_count(animation) - 1
		Player.State.WALK:
			_play_walk_animations()
		Player.State.SPRINT:
			_play_walk_animations(1.5)
		Player.State.PUSH:
			play("push_up")
			flip_h = false
		Player.State.REST:
			play("rest")
			flip_h = false


func _play_walk_animations(speed: float = 1.0) -> void:
	if player.velocity.y < 0:
		play("walk_up", speed)
	elif player.velocity.y > 0:
		play("walk_down", speed)
	elif player.velocity.x < 0:
		play("walk_left", speed)
	elif player.velocity.x > 0:
		play("walk_left", speed)
	flip_h = player.velocity.y == 0 and player.velocity.x > 0

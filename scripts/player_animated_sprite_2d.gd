class_name PlayerAnimatedSprite2D
extends AnimatedSprite2D

@export var player: Player

var postfix_by_direction: Dictionary[Vector2i, String] = {
	Vector2i.UP: "up",
	Vector2i.DOWN: "down",
	Vector2i.LEFT: "left",
	# there are no "right" frames, so the sprite is flipped instead, cmp. flip_h
	Vector2i.RIGHT: "left",
}

func _process(_delta: float) -> void:
	var postfix = postfix_by_direction[player.view_direction]

	match player.state:
		Player.State.IDLE:
			animation = "walk_%s" % postfix
			stop()
			# Stop on the last frame, because I've made the last frames look idle
			# so the first frame is always in movement.
			# Otherwise the player appears to slide while an animation starts.
			frame = sprite_frames.get_frame_count(animation) - 1
		Player.State.WALK:
			play("walk_%s" % postfix)
		Player.State.SPRINT:
			play("walk_%s" % postfix, 1.5)
		Player.State.PUSH:
			play("push_%s" % postfix)
		Player.State.REST:
			play("rest")
		Player.State.PUNCH:
			play("punch_%s" % postfix)

	flip_h = player.view_direction == Vector2i.RIGHT

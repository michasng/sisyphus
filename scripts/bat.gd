class_name Bat
extends CharacterBody2D

@export var target: Node2D

@export var follow_from_distance_pixels := Game.TILE_SIZE_PIXELS * 5
@export var velocity_pixels_per_second := 1.0 * Game.TILE_SIZE_PIXELS

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var initial_sprite_offset := _animated_sprite.offset
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _hurt_box: Area2D = $HurtBox
@onready var _flap_sound_effect: SoundEffect = $FlapSoundEffect
@onready var _die_sound_effect: SoundEffect = $DieSoundEffect

var is_following_target := false


func _physics_process(_delta: float) -> void:
	if not target:
		return

	var distance = global_position.distance_to(target.global_position)
	is_following_target = distance <= follow_from_distance_pixels
	if not is_following_target:
		return

	var direction = global_position.direction_to(target.global_position)

	if direction.x != 0:
		_animated_sprite.flip_h = direction.x < 0
		_animated_sprite.offset = -initial_sprite_offset if _animated_sprite.flip_h else initial_sprite_offset

	velocity = direction * velocity_pixels_per_second
	move_and_slide()


func _on_hurt_box_area_entered(_area: Area2D) -> void:
	_animated_sprite.play("die")
	_die_sound_effect.resume()
	# must set_defferred, because _hurt_box.monitorable is blocked during signal callback
	_hurt_box.set_deferred("monitorable", false)
	target = null
	_animation_player.play("die")
	await get_tree().create_timer(0.2).timeout
	queue_free()


func _on_animation_looped() -> void:
	if is_following_target:
		_flap_sound_effect.resume()


func _on_button_sensor_area_entered(_area: Area2D) -> void:
	target = null
	is_following_target = false

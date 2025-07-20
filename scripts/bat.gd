class_name Bat
extends CharacterBody2D

@export var target: Node2D

@export var follow_from_distance_pixels := Game.TILE_SIZE_PIXELS * 5
@export var velocity_pixels_per_second := 1.0 * Game.TILE_SIZE_PIXELS

@onready var _flap_sound_effect: SoundEffect = $FlapSoundEffect

var is_following_target := false


func _physics_process(_delta: float) -> void:
	if not target:
		return
	
	var distance = global_position.distance_to(target.global_position)
	is_following_target = distance <= follow_from_distance_pixels
	if not is_following_target:
		return

	var direction = global_position.direction_to(target.global_position)
	velocity = direction * velocity_pixels_per_second
	move_and_slide()


func _on_hurt_box_area_entered(_area: Area2D) -> void:
	queue_free()


func _on_animation_looped() -> void:
	if is_following_target:
		_flap_sound_effect.resume()

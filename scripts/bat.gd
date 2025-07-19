class_name Bat
extends CharacterBody2D

@export var target: Node2D

@export var follow_from_distance_pixels := Game.TILE_SIZE_PIXELS * 5
@export var velocity_pixels_per_second := 1.0 * Game.TILE_SIZE_PIXELS


func _physics_process(_delta: float) -> void:
	if not target:
		return
	
	var distance = global_position.distance_to(target.global_position)
	if distance > follow_from_distance_pixels:
		return
	
	var direction = global_position.direction_to(target.global_position)
	velocity = direction * velocity_pixels_per_second
	move_and_slide()


func _on_hurt_box_area_entered(_area: Area2D) -> void:
	queue_free()

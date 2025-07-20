class_name BatSpawner
extends Node2D

@export var target: Node2D
@export var spawn_distance_pixels := Game.TILE_SIZE_PIXELS * 5
@export var spawn_count := 4

@onready var _bat_scene: PackedScene = preload("res://scenes/bat.tscn")


func _process(_delta: float) -> void:
	if position.distance_to(target.position) > spawn_distance_pixels:
		return

	if get_child_count() >= spawn_count:
		return

	var bat: Bat = _bat_scene.instantiate()
	bat.target = target
	add_child(bat)

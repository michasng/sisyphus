class_name GameCamera
extends Camera2D

@export var target: Node2D


func _process(_delta: float) -> void:
	if target.position.y <= 0:
		position.y = target.position.y

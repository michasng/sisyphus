class_name Game
extends Node2D

const TILE_SIZE_PIXELS: int = 16

@onready var boulder: Boulder = $YSorted/Boulder
@onready var camera: GameCamera = $GameCamera


func _on_boulder_state_changed(previous_state: Boulder.State, _current_state: Boulder.State) -> void:
	if previous_state == Boulder.State.ROLL and boulder.velocity.y > 20.0:
		camera.shake(0.5)

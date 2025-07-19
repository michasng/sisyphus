class_name Game
extends Node2D

const TILE_SIZE_PIXELS: int = 16

@onready var boulder: Boulder = $YSorted/Boulder
@onready var camera: GameCamera = $GameCamera
@onready var heads_up_display: HeadsUpDisplay = $GameCamera/HeadsUpDisplay


func _ready() -> void:
	await get_tree().create_timer(4.0).timeout
	heads_up_display.text = "Zeus: Sisyphus, you cheat!
	  Enjoy your rock."


func _on_boulder_state_changed(previous_state: Boulder.State, _current_state: Boulder.State) -> void:
	if previous_state == Boulder.State.ROLL and boulder.velocity.y > 20.0:
		camera.shake(0.5)
		boulder.stop_sound_effect.play()


func _on_player_hurt() -> void:
	camera.shake(0.5, 0.2)


func _on_sign_read(text: Variant) -> void:
	heads_up_display.text = text

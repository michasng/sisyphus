class_name Game
extends Node2D

const TILE_SIZE_PIXELS: int = 16

@onready var player: Player = $YSorted/Player
@onready var boulder: Boulder = $YSorted/Boulder
@onready var camera: GameCamera = $GameCamera
@onready var heads_up_display: HeadsUpDisplay = $GameCamera/HeadsUpDisplay


func _ready() -> void:
	player.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(4.0).timeout # wait for boulder to roll down
	heads_up_display.text = "Zeus: Sisyphus, you cheat!\n      Enjoy your rock."
	await get_tree().create_timer(heads_up_display.text_display_seconds).timeout
	player.process_mode = Node.PROCESS_MODE_INHERIT


func _on_boulder_state_changed(previous_state: Boulder.State, _current_state: Boulder.State) -> void:
	if previous_state == Boulder.State.ROLL and boulder.velocity.y > 20.0:
		camera.shake(0.5)
		boulder.stop_sound_effect.play()


func _on_player_hurt() -> void:
	camera.shake(0.5, 0.2)


func _on_sign_read(text: Variant) -> void:
	heads_up_display.text = text


func _on_mountain_top_body_entered(body: Node2D) -> void:
	if body == boulder:
		heads_up_display.text = "Zeus: Congratulations Sisyphus!\n      You can start right over, lol."
		await get_tree().create_timer(heads_up_display.text_display_seconds).timeout
		(get_tree().root.get_child(0) as Root).restart_game()
	else:
		heads_up_display.text = "Zeus: Looks like you're a few rocks short of a full boulder."

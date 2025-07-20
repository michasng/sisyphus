class_name Root
extends Node2D

@onready var title: Title = $Title
var game: Game

@onready var title_music: AudioStreamPlayer = $TitleMusic
@onready var game_music: AudioStreamPlayer = $GameMusic


func start_game() -> void:
	game = _create_game()
	title.queue_free()
	title = null
	add_child(game)


func restart_game() -> void:
	game.queue_free()
	game = _create_game()
	add_child(game)
	game_music.play()


func _create_game() -> Game:
	var scene: PackedScene = load("res://scenes/game.tscn")
	return scene.instantiate()


func _on_title_music_finished() -> void:
	if game == null:
		title_music.play() # loop
	else:
		game_music.play()


func _on_game_music_finished() -> void:
	game_music.play() # loop

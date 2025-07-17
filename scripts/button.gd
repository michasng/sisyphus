class_name ButtonTile
extends Area2D

@onready var up_sprite: Sprite2D = $UpSprite2D
@onready var down_sprite: Sprite2D = $DownSprite2D

signal pressed


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node2D) -> void:
	up_sprite.visible = false
	down_sprite.visible = true
	pressed.emit()

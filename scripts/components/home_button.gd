class_name HomeButton
extends Control

@onready var home_button: TextureButton = %HomeButton
@export_file("*.tscn") var target_scene_path: String = "res://scenes/ui/game_menu.tscn"

func _ready() -> void:
	home_button.pressed.connect(return_home)

func return_home() -> void:
	sound_manager.play("Click")
	get_tree().change_scene_to_file(target_scene_path)

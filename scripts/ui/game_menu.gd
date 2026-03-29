class_name GameMenu
extends Control

const COMMERCIAL_SCENE = preload("uid://d2xguvgncyliw")
@onready var start_game_button: ActionButton = %StartGameButton

func _ready() -> void:
	sound_manager.play("EnterGame")
	start_game_button.pressed.connect(start_game)

func start_game() -> void:
	sound_manager.play("EnterGame")
	get_tree().change_scene_to_packed(COMMERCIAL_SCENE)

func show_about_us() -> void:
	ui_manager.open_about_us_modal()
	sound_manager.play("Click")

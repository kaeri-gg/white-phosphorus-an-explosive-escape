class_name GameMenu
extends Control

const FACT_SCENE = preload("uid://d2xguvgncyliw")
@onready var start_game_button: ActionButton = %StartGameButton

@export var fade_duration: float = 0.6

func _ready() -> void:
	sound_manager.play("EnterGame")
	utils.fade_from_overlay(fade_duration)
	start_game_button.pressed.connect(start_game)

func start_game() -> void:
	sound_manager.play("EnterGame")
	await utils.fade_to_white(self, fade_duration)
	get_tree().change_scene_to_packed(FACT_SCENE)

func show_about_us() -> void:
	ui_manager.open_about_us_modal()
	sound_manager.play("Click")

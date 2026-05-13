class_name GameMenu
extends Control

const FACT_SCENE = preload("uid://d2xguvgncyliw")

@onready var next_button: ActionButton = %GameEnterButton
@onready var about_link_button: TextureButton = %AboutLinkButton

@export var fade_duration: float = UiConstants.DEFAULT_FADE_DURATION

func _ready() -> void:
	sound_manager.play("EnterGame")
	utils.fade_from_overlay(fade_duration)
	next_button.pressed.connect(start_game)
	about_link_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func start_game() -> void:
	sound_manager.play("EnterGame")
	await utils.fade_to_white(self, fade_duration)
	get_tree().change_scene_to_packed(FACT_SCENE)

func show_about_us() -> void:
	ui_manager.open_about_us_modal()
	sound_manager.play("Click")

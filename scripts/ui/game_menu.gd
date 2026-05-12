class_name GameMenu
extends Control

const FACT_SCENE = preload("uid://d2xguvgncyliw")

@onready var next_button: ActionButton = %NextScreen
@onready var about_link_button: TextureButton = %AboutLinkButton

@export var fade_duration: float = UiConstants.DEFAULT_FADE_DURATION

var _about_hovered := false

func _ready() -> void:
	sound_manager.play("EnterGame")
	utils.fade_from_overlay(fade_duration)
	next_button.pressed.connect(start_game)
	about_link_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	about_link_button.mouse_entered.connect(_on_about_mouse_entered)
	about_link_button.mouse_exited.connect(_on_about_mouse_exited)
	about_link_button.button_down.connect(_on_about_button_down)
	about_link_button.button_up.connect(_on_about_button_up)

func _on_about_mouse_entered() -> void:
	_about_hovered = true
	about_link_button.modulate = UiConstants.HOVER_MODULATE

func _on_about_mouse_exited() -> void:
	_about_hovered = false
	about_link_button.modulate = UiConstants.NORMAL_MODULATE

func _on_about_button_down() -> void:
	about_link_button.modulate = UiConstants.PRESS_MODULATE

func _on_about_button_up() -> void:
	about_link_button.modulate = UiConstants.HOVER_MODULATE if _about_hovered else UiConstants.NORMAL_MODULATE

func start_game() -> void:
	sound_manager.play("EnterGame")
	await utils.fade_to_white(self, fade_duration)
	get_tree().change_scene_to_packed(FACT_SCENE)

func show_about_us() -> void:
	ui_manager.open_about_us_modal()
	sound_manager.play("Click")

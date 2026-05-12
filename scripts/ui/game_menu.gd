class_name GameMenu
extends Control

const FACT_SCENE = preload("uid://d2xguvgncyliw")

const HOVER_MODULATE := Color(1.15, 1.15, 1.15)
const PRESS_MODULATE := Color(0.85, 0.85, 0.85)
const NORMAL_MODULATE := Color(1.0, 1.0, 1.0)

@onready var next_button: ActionButton = %NextScreen
@onready var about_link_button: TextureButton = %AboutLinkButton

@export var fade_duration: float = 0.6

var _next_hovered := false
var _about_hovered := false

func _ready() -> void:
	sound_manager.play("EnterGame")
	utils.fade_from_overlay(fade_duration)
	next_button.pressed.connect(start_game)
	next_button.mouse_entered.connect(_on_next_mouse_entered)
	next_button.mouse_exited.connect(_on_next_mouse_exited)
	next_button.button_down.connect(_on_next_button_down)
	next_button.button_up.connect(_on_next_button_up)
	about_link_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	about_link_button.mouse_entered.connect(_on_about_mouse_entered)
	about_link_button.mouse_exited.connect(_on_about_mouse_exited)
	about_link_button.button_down.connect(_on_about_button_down)
	about_link_button.button_up.connect(_on_about_button_up)

func _on_next_mouse_entered() -> void:
	_next_hovered = true
	next_button.modulate = HOVER_MODULATE

func _on_next_mouse_exited() -> void:
	_next_hovered = false
	next_button.modulate = NORMAL_MODULATE

func _on_next_button_down() -> void:
	next_button.modulate = PRESS_MODULATE

func _on_next_button_up() -> void:
	if _next_hovered:
		next_button.modulate = HOVER_MODULATE
	else:
		next_button.modulate = NORMAL_MODULATE

func _on_about_mouse_entered() -> void:
	_about_hovered = true
	about_link_button.modulate = HOVER_MODULATE

func _on_about_mouse_exited() -> void:
	_about_hovered = false
	about_link_button.modulate = NORMAL_MODULATE

func _on_about_button_down() -> void:
	about_link_button.modulate = PRESS_MODULATE

func _on_about_button_up() -> void:
	if _about_hovered:
		about_link_button.modulate = HOVER_MODULATE
	else:
		about_link_button.modulate = NORMAL_MODULATE

func start_game() -> void:
	sound_manager.play("EnterGame")
	await utils.fade_to_white(self, fade_duration)
	get_tree().change_scene_to_packed(FACT_SCENE)

func show_about_us() -> void:
	ui_manager.open_about_us_modal()
	sound_manager.play("Click")

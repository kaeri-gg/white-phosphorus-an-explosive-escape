class_name ActionButton
extends Control

signal pressed

@export var custom_label_text: String = "Button label"
@export var theme_variation: String = ""
@export var enable_space_shortcut: bool = true
@export var texture: Texture2D

const HOVER_MODULATE := Color(1.15, 1.15, 1.15)
const PRESS_MODULATE := Color(0.85, 0.85, 0.85)
const NORMAL_MODULATE := Color(1.0, 1.0, 1.0)

@onready var button: TextureButton = %Button
var hovered = false
var _pressed = false

func _ready() -> void:
#	button.text = custom_label_text
	if not theme_variation.is_empty():
		button.theme_type_variation = theme_variation
	if texture:
		button.texture_normal = texture
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if enable_space_shortcut:
		var shortcut := Shortcut.new()
		var event := InputEventKey.new()
		event.physical_keycode = KEY_SPACE
		shortcut.events = [event]
		button.shortcut = shortcut

	button.pressed.connect(_on_button_pressed)
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	hovered = true
	if not _pressed:
		modulate = HOVER_MODULATE

func _on_mouse_exited() -> void:
	hovered = false
	if not _pressed:
		modulate = NORMAL_MODULATE

func _on_button_down() -> void:
	_pressed = true
	modulate = PRESS_MODULATE

func _on_button_up() -> void:
	_pressed = false
	if hovered:
		modulate = HOVER_MODULATE
	else:
		modulate = NORMAL_MODULATE

func _on_button_pressed() -> void:
	pressed.emit()

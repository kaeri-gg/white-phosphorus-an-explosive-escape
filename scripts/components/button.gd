class_name ActionButton
extends Control

signal pressed

@export var custom_label_text: String = "Button label"
@export var theme_variation: String = ""
@export var enable_space_shortcut: bool = true
@export var texture: Texture2D
@export_range(0.1, 1.0) var pressed_opacity: float = 0.5
@export_range(0.1, 1.0) var hover_opacity: float = 0.8

@onready var button: TextureButton = %Button
var hovered = false
var _pressed = false

func _ready() -> void:
#	button.text = custom_label_text
	if not theme_variation.is_empty():
		button.theme_type_variation = theme_variation
	if texture:
		button.texture_normal = texture

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
		modulate.a = hover_opacity

func _on_mouse_exited() -> void:
	hovered = false
	if not _pressed:
		modulate.a = 1.0

func _on_button_down() -> void:
	_pressed = true
	modulate.a = pressed_opacity

func _on_button_up() -> void:
	_pressed = false
	if hovered:
		modulate.a = hover_opacity
	else:
		modulate.a = 1.0

func _on_button_pressed() -> void:
	pressed.emit()

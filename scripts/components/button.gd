class_name ActionButton
extends Control

signal pressed

@export var custom_label_text: String = "Button label"
@export var theme_variation: String = ""
@export var enable_space_shortcut: bool = true

@onready var button: Button = %Button

func _ready() -> void:
	button.text = custom_label_text
	if not theme_variation.is_empty():
		button.theme_type_variation = theme_variation

	if enable_space_shortcut:
		var shortcut := Shortcut.new()
		var event := InputEventKey.new()
		event.physical_keycode = KEY_SPACE
		shortcut.events = [event]
		button.shortcut = shortcut

	button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	pressed.emit()

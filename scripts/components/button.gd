class_name ActionButton
extends Control

signal pressed

@export var custom_label_text: String = "Button label"
@export var theme_variation: String = ""
@onready var button: Button = %Button

func _ready() -> void:
	button.text = custom_label_text
	if not theme_variation.is_empty():
		button.theme_type_variation = theme_variation
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	pressed.emit()

class_name ActionButton
extends Control

signal pressed

@export var custom_label_text: String = "Button label"
@onready var button: Button = %Button

func _ready() -> void:
	button.text = custom_label_text
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	pressed.emit()

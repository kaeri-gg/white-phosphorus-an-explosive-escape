class_name CloseButton
extends Control

signal clicked

@onready var close_button: TextureButton = %CloseButton
var hovered = false

func _ready() -> void:
	close_button.pressed.connect(close_self)
	close_button.mouse_entered.connect(_on_mouse_entered)
	close_button.mouse_exited.connect(_on_mouse_exited)
	close_button.button_down.connect(_on_button_down)
	close_button.button_up.connect(_on_button_up)

func _on_mouse_entered() -> void:
	hovered = true
	modulate.a = 0.8

func _on_mouse_exited() -> void:
	hovered = false
	modulate.a = 1.0

func _on_button_down() -> void:
	modulate.a = 0.5

func _on_button_up() -> void:
	if hovered:
		modulate.a = 0.8
	else:
		modulate.a = 1.0

func close_self() -> void:
	sound_manager.play("Click")
	clicked.emit()

class_name HelpButton
extends Control

@onready var help_button: TextureButton = %HelpButton
var hovered = false

func _ready() -> void:
	if help_button and not help_button.pressed.is_connected(toggle_tutorial):
		help_button.pressed.connect(toggle_tutorial)
	help_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	help_button.mouse_entered.connect(_on_mouse_entered)
	help_button.mouse_exited.connect(_on_mouse_exited)
	help_button.button_down.connect(_on_button_down)
	help_button.button_up.connect(_on_button_up)

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

func toggle_tutorial() -> void:
	sound_manager.play("Click")
	ui_manager.toggle_tutorial_modal()

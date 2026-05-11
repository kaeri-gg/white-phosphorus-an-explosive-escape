class_name SettingsButton
extends Control

signal on_click

@onready var settings_button: TextureButton = %SettingsButton
var hovered = false

func _ready() -> void:
	settings_button.pressed.connect(open_settings)
	settings_button.mouse_entered.connect(_on_mouse_entered)
	settings_button.mouse_exited.connect(_on_mouse_exited)
	settings_button.button_down.connect(_on_button_down)
	settings_button.button_up.connect(_on_button_up)

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

func _unhandled_input(event: InputEvent) -> void:
	if !(event is InputEventKey):
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode != KEY_ESCAPE:
		return

	ui_manager.toggle_settings_modal()
	get_viewport().set_input_as_handled()

func open_settings() -> void:
	ui_manager.open_settings_modal()
	sound_manager.play("Click")
	on_click.emit()
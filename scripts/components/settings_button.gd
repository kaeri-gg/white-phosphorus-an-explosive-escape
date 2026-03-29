class_name SettingsButton
extends Control

signal on_click

@onready var settings_button: TextureButton = %SettingsButton

func _ready() -> void:
	settings_button.pressed.connect(open_settings)

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

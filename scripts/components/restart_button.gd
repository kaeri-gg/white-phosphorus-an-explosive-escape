class_name RestartButton
extends Control

@onready var restart_button: TextureButton = %RestartButton

func _ready() -> void:
	if restart_button and not restart_button.pressed.is_connected(restart_level):
		restart_button.pressed.connect(restart_level)
func _unhandled_input(event: InputEvent) -> void:
	if !(event is InputEventKey):
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode != KEY_R:
		return

	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
	restart_level()

func restart_level() -> void:
	sound_manager.play("Click")
	get_tree().reload_current_scene()

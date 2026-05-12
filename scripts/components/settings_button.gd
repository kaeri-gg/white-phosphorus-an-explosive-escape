class_name SettingsButton
extends HoverableButton

func _on_inner_pressed() -> void:
	open_settings()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_settings"):
		return
	sound_manager.play("Click")
	ui_manager.toggle_settings_modal()
	get_viewport().set_input_as_handled()

func open_settings() -> void:
	sound_manager.play("Click")
	ui_manager.open_settings_modal()

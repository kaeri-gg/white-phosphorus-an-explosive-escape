class_name SettingsButton
extends HoverableButton

func _ready() -> void:
	super._ready()
	# Suppress tooltip for the first frame so the initial spurious mouse_entered
	# (fired before the user moves the mouse) doesn't queue the tooltip popup.
	var btn := _inner_button
	if btn == null:
		return
	var saved := btn.tooltip_text
	btn.tooltip_text = ""
	await get_tree().process_frame
	btn.tooltip_text = saved

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

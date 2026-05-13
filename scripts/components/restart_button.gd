class_name RestartButton
extends HoverableButton

func _on_inner_pressed() -> void:
	restart_level()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_restart"):
		return
	get_viewport().set_input_as_handled()
	restart_level()

func restart_level() -> void:
	sound_manager.play("Click")
	get_tree().reload_current_scene()

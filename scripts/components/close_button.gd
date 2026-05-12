class_name CloseButton
extends HoverableButton

func _on_inner_pressed() -> void:
	sound_manager.play("Click")
	pressed.emit()

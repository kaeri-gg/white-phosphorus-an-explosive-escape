class_name HelpButton
extends HoverableButton

func _on_inner_pressed() -> void:
	toggle_tutorial()

func toggle_tutorial() -> void:
	sound_manager.play("Click")
	ui_manager.toggle_tutorial_modal()

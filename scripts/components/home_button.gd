class_name HomeButton
extends HoverableButton

@export_file("*.tscn") var target_scene_path: String = "uid://4ht2ox1qqc7q"
@export var fade_duration: float = UiConstants.DEFAULT_FADE_DURATION

func _on_inner_pressed() -> void:
	return_home()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_backhome"):
		return
	get_viewport().set_input_as_handled()
	return_home()

func return_home() -> void:
	sound_manager.play("Click")
	var tree := get_tree()
	await utils.fade_to_white(tree.current_scene, fade_duration)
	tree.change_scene_to_file(target_scene_path)

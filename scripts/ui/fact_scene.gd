class_name FactScene
extends Control

@export_file("*.tscn") var next_scene_path: String = ""
@export var fade_duration: float = 0.6

func _ready() -> void:
	sound_manager.play("EnterGame")
	utils.fade_from_overlay(fade_duration)
	_wire_button("ProceedButton", next_scene_path)

func _wire_button(unique_name: String, scene_path: String) -> void:
	var button: ActionButton = get_node_or_null("%" + unique_name)
	if not button:
		return
	for connection in button.pressed.get_connections():
		button.pressed.disconnect(connection.callable)
	button.pressed.connect(_change_scene.bind(scene_path))

func _on_proceed_button_pressed() -> void:
	_change_scene(next_scene_path)

func _change_scene(path: String) -> void:
	if path.is_empty():
		push_warning("%s is missing a scene path." % name)
		return

	var resolved_scene_path: String = ResourceUID.ensure_path(path)
	if resolved_scene_path.is_empty():
		push_warning("%s could not resolve scene path: %s" % [name, path])
		return

	sound_manager.play("EnterGame")
	await utils.fade_to_white(self, fade_duration)
	get_tree().change_scene_to_file(resolved_scene_path)

class_name FactScene
extends Control

@export_file("*.tscn") var next_scene_path: String = ""
@export_file("*.tscn") var level_1_pat_scene: String = "res://scenes/levels/level_01.tscn"
@export_file("*.tscn") var level_2_pat_scene: String = "res://scenes/levels/level_02.tscn"
@export_file("*.tscn") var level_1_anna_scene: String = "res://scenes/levels/level_01_v2.tscn"
@export_file("*.tscn") var level_2_anna_scene: String = "res://scenes/levels/level_02_v2.tscn"

func _ready() -> void:
	sound_manager.play("EnterGame")
	_wire_button("ProceedButton", next_scene_path)
	_wire_button("Level_1_Pat", level_1_pat_scene)
	_wire_button("Level_2_Pat", level_2_pat_scene)
	_wire_button("Level_1_Anna", level_1_anna_scene)
	_wire_button("Level_2_Anna", level_2_anna_scene)

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
	get_tree().change_scene_to_file(resolved_scene_path)

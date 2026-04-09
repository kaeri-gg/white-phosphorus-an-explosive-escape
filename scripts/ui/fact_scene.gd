class_name FactScene
extends Control

@export_file("*.tscn") var next_scene_path: String = ""

@onready var proceed_button: ActionButton = %ProceedButton

func _ready() -> void:
	sound_manager.play("EnterGame")
	proceed_button.pressed.connect(_on_proceed_button_pressed)

func _on_proceed_button_pressed() -> void:
	if next_scene_path.is_empty():
		push_warning("%s is missing a Next Scene in the inspector." % name)
		return

	var resolved_scene_path: String = ResourceUID.ensure_path(next_scene_path)
	if resolved_scene_path.is_empty():
		push_warning("%s could not resolve scene path: %s" % [name, next_scene_path])
		return

	sound_manager.play("EnterGame")
	get_tree().change_scene_to_file(resolved_scene_path)

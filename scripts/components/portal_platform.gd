class_name PortalPlatform
extends StaticBody2D

@export_file("*.tscn") var next_scene_path: String = ""

@onready var portal_area: Area2D = $PortalArea

var is_transitioning: bool = false

func _ready() -> void:
	portal_area.body_entered.connect(_show_next_scene)

func _show_next_scene(body: Node) -> void:
	if is_transitioning:
		return

	if not (body is Player):
		return

	if next_scene_path.is_empty():
		push_warning("%s is missing a Next Scene in the inspector." % name)
		return

	var resolved_scene_path: String = ResourceUID.ensure_path(next_scene_path)
	if resolved_scene_path.is_empty():
		push_warning("%s could not resolve scene path: %s" % [name, next_scene_path])
		return

	is_transitioning = true
	sound_manager.play("EnterGame")
	
	await utils.fade_out(get_tree().current_scene, 0.5)
	get_tree().change_scene_to_file(resolved_scene_path)

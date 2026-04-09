class_name PortalPlatform
extends StaticBody2D

@export_file("*.tscn") var next_scene_path: String = ""

@onready var portal_area: Area2D = $PortalArea

var is_transitioning: bool = false

func _ready() -> void:
	portal_area.body_entered.connect(_on_portal_area_body_entered)

func _on_portal_area_body_entered(body: Node) -> void:
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
	await utils.timeout(1)
	sound_manager.play("EnterGame")
	
	call_deferred("_change_to_scene", resolved_scene_path)
	
func _change_to_scene(scene_path: String) -> void:
	var result: Error = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		is_transitioning = false
		push_warning("%s failed to change scene to %s (error %s)." % [name, scene_path, result])

extends Area2D

@export_file("*.tscn") var next_scene_path: String = ""

var is_transitioning: bool = false

func _ready() -> void:
	body_entered.connect(_show_next_scene)

func _show_next_scene(body: Node) -> void:
	if is_transitioning or not (body is Player):
		return

	if next_scene_path.is_empty():
		push_warning("%s is missing a Next Scene in the inspector." % get_parent().name)
		return

	var resolved := ResourceUID.ensure_path(next_scene_path)
	if resolved.is_empty():
		push_warning("Could not resolve scene path: %s" % next_scene_path)
		return

	is_transitioning = true
	sound_manager.play("EnterGame")
	get_tree().call_deferred("change_scene_to_file", resolved)

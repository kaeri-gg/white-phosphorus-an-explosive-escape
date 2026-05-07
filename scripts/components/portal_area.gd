extends Area2D

@export_file("*.tscn") var next_scene_path: String = ""
@export var fade_duration: float = 0.6

var is_transitioning: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	if is_transitioning:
		return
	for body in get_overlapping_bodies():
		if body is Player:
			_try_advance(body as Player)
			return

func _on_body_entered(body: Node) -> void:
	if body is Player:
		_try_advance(body as Player)

func _try_advance(player: Player) -> void:
	if is_transitioning:
		return
	if player.current_state != Player.STATE.STABLE:
		return

	if next_scene_path.is_empty():
		push_warning("%s is missing a Next Scene." % get_parent().name)
		return

	var resolved := ResourceUID.ensure_path(next_scene_path)
	if resolved.is_empty():
		push_warning("Could not resolve: %s" % next_scene_path)
		return

	is_transitioning = true
	sound_manager.play("EnterGame")
	await utils.fade_to_white(get_tree().current_scene, fade_duration)
	get_tree().change_scene_to_file(resolved)

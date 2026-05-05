class_name FinalPlatform
extends StaticBody2D

@export_file("*.tscn") var next_scene_path: String = ""
@export var stable_delay: float = 2.0
@export var fade_duration: float = 0.6

@onready var detection_area: Area2D = %DetectionArea
@onready var stable_timer: Timer = %StableTimer

var current_player: Player
var has_triggered: bool = false

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	stable_timer.wait_time = stable_delay
	stable_timer.one_shot = true
	stable_timer.timeout.connect(_on_stable_timeout)

func _on_body_entered(body: Node) -> void:
	if has_triggered or body is not Player:
		return
	current_player = body
	body.enter_water()
	stable_timer.start()

func _on_body_exited(body: Node) -> void:
	if has_triggered or body != current_player:
		return
	if is_instance_valid(current_player):
		current_player.leave_water()
	current_player = null
	stable_timer.stop()

func _on_stable_timeout() -> void:
	if current_player == null or not is_instance_valid(current_player):
		return
	has_triggered = true
	await current_player.transform_to_final_form()

	if next_scene_path.is_empty():
		return
	var resolved := ResourceUID.ensure_path(next_scene_path)
	if resolved.is_empty():
		push_warning("FinalPlatform could not resolve scene: %s" % next_scene_path)
		return
	await utils.fade_to_white(get_tree().current_scene, fade_duration)
	get_tree().change_scene_to_file(resolved)

class_name Level
extends Control

@export var fade_duration: float = UiConstants.DEFAULT_FADE_DURATION
@export var show_tutorial_on_start: bool = false

@onready var player: Player = $Player
@onready var timer_label: Label = find_child("TimerLabel", true, false) as Label

var _respawn_position: Vector2

func _ready() -> void:
	utils.fade_from_overlay(fade_duration)
	player.health_timer_value.connect(_on_health_timer_updated)
	player.died.connect(_on_player_died)
	_on_health_timer_updated(player.time_until_next_damage())
	if show_tutorial_on_start:
		ui_manager.open_tutorial_modal_once()

	_respawn_position = player.global_position
	for point in get_tree().get_nodes_in_group("respawn_points"):
		if point is RespawnPoint:
			point.activated.connect(_on_respawn_point_activated)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_help"):
		sound_manager.play("Click")
		ui_manager.toggle_tutorial_modal()
		get_viewport().set_input_as_handled()

func _on_health_timer_updated(time_left: float) -> void:
	if timer_label != null:
		timer_label.text = "%.1f" % time_left

func _on_respawn_point_activated(point: RespawnPoint) -> void:
	_respawn_position = point.global_position
	for p in get_tree().get_nodes_in_group("respawn_points"):
		if p is RespawnPoint:
			p.set_active(p == point)

func _on_player_died() -> void:
	await get_tree().create_timer(0.3).timeout
	await utils.fade_to_black(self, 1.0)
	player.global_position = _respawn_position
	player.respawn()
	utils.fade_from_overlay(fade_duration)

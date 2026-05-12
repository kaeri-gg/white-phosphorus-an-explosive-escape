class_name Level
extends Control

@export var fade_duration: float = 0.6
@export var show_tutorial_on_start: bool = false

@onready var player: Player = $Player
@onready var timer_label: Label = find_child("TimerLabel", true, false) as Label

func _ready() -> void:
	utils.fade_from_overlay(fade_duration)
	player.health_timer_value.connect(_on_health_timer_updated)
	player.died.connect(_on_player_died)
	_on_health_timer_updated(player.time_until_next_damage())
	if show_tutorial_on_start:
		ui_manager.open_tutorial_modal_once()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		sound_manager.play("Click")
		ui_manager.toggle_settings_modal()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_H:
		sound_manager.play("Click")
		ui_manager.toggle_tutorial_modal()
		get_viewport().set_input_as_handled()

func _on_health_timer_updated(time_left: float) -> void:
	if timer_label != null:
		timer_label.text = "%.1f" % time_left

func _on_player_died() -> void:
	await get_tree().create_timer(0.3).timeout
	await utils.fade_to_black(self, 1.0)
	get_tree().reload_current_scene()

class_name Level
extends Control

@onready var player: Player = $Player
@onready var timer_label: Label = find_child("TimerLabel", true, false) as Label

func _ready() -> void:
	player.die_timer_value.connect(_on_timer_updated)
	player.died.connect(_on_player_died)
	_on_timer_updated(player.remaining_survival_timer_value())
	
func _on_timer_updated(time_left: float) -> void:
	if timer_label != null:
		timer_label.text = "%.1f" % time_left

func _on_player_died() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

class_name Level
extends Control

@onready var player: Player = $Player
@onready var timer_label: Label = find_child("TimerLabel", true, false) as Label

func _ready() -> void:
	player.air_timer_value.connect(_on_timer_updated)
	_on_timer_updated(player.update_timer_display())
	
func _on_timer_updated(time_left: float) -> void:
	if timer_label != null:
		timer_label.text = "%.1f" % time_left

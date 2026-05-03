class_name Level
extends Control

@onready var player: Player = $Player
@onready var timer_label: Label = find_child("TimerLabel", true, false) as Label

func _ready() -> void:
	player.health_timer_value.connect(_on_health_timer_updated)
	player.died.connect(_on_player_died)
	_on_health_timer_updated(player.time_until_next_damage())

func _on_health_timer_updated(time_left: float) -> void:
	if timer_label != null:
		timer_label.text = "%.1f" % time_left

func _on_player_died() -> void:
	# Player.died fires after the dead anim has finished and the player
	# has been hidden. Hold for a beat, fade to black, then restart.
	await get_tree().create_timer(0.3).timeout
	await utils.fade_to_black(self, 1.0)
	get_tree().reload_current_scene()

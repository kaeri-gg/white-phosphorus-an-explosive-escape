class_name Level
extends Control

@onready var player: Player = $Player
@onready var timer_label: Label = $Timer/TimerLabel
@onready var next_button: ActionButton = $NextButton

const LEVEL_02 = preload("res://scenes/levels/level_02.tscn")

func _ready() -> void:
	player.air_timer_value.connect(_on_timer_updated)
	_on_timer_updated(player.get_timer_display_value())
	next_button.pressed.connect(_next_button_clicked)

func _on_timer_updated(time_left: float) -> void:
	timer_label.text = "%.1f" % time_left

func _next_button_clicked() -> void:
	get_tree().change_scene_to_packed(LEVEL_02)

@tool
class_name RespawnPoint
extends Area2D

signal activated(point: RespawnPoint)

var is_active: bool = false

@onready var _toast_panel: Control = $ToastLayer/ToastPanel

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	add_to_group("respawn_points")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player and not is_active:
		activated.emit(self)
		_show_toast()

func set_active(value: bool) -> void:
	is_active = value
	queue_redraw()

func _show_toast() -> void:
	var tween := create_tween()
	tween.tween_property(_toast_panel, "modulate:a", 1.0, 0.3) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.5)
	tween.tween_property(_toast_panel, "modulate:a", 0.0, 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

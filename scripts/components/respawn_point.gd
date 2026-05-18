@tool
class_name RespawnPoint
extends Area2D

signal activated(point: RespawnPoint)

var is_active: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	add_to_group("respawn_points")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Player and not is_active:
		activated.emit(self)

func set_active(value: bool) -> void:
	is_active = value
	queue_redraw()

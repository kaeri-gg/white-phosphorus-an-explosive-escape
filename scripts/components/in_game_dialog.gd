class_name InGameDialog
extends Area2D

# A world-space tutorial-dialog trigger.
#
# Place an InGameDialog in a level, size its CollisionShape2D to taste, and
# set `dialog_text` in the inspector. When the Player enters the area, the
# bubble appears and types the text out character-by-character. When the
# Player leaves, the bubble hides; the next entry replays the typing
# animation from the start.

## The text that will be typed out when the player enters this trigger.
@export_multiline var dialog_text: String = "Press [space] to jump."

## How fast the text types out, in characters per second.
@export var chars_per_second: float = 30.0

@onready var canvas_layer: CanvasLayer = %DialogCanvasLayer
@onready var label: Label = %DialogLabel

var _typing_tween: Tween

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	label.text = dialog_text
	label.visible_characters = 0
	canvas_layer.visible = false

func _on_body_entered(body: Node) -> void:
	if body is Player:
		_show_and_type()

func _on_body_exited(body: Node) -> void:
	if body is Player:
		_hide()

func _show_and_type() -> void:
	if _typing_tween:
		_typing_tween.kill()

	label.text = dialog_text
	label.visible_characters = 0
	canvas_layer.visible = true

	var total_chars: int = dialog_text.length()
	if total_chars <= 0:
		return

	var duration: float = max(0.05, float(total_chars) / max(1.0, chars_per_second))
	_typing_tween = create_tween()
	_typing_tween.tween_property(label, "visible_characters", total_chars, duration)

func _hide() -> void:
	if _typing_tween:
		_typing_tween.kill()
		_typing_tween = null
	canvas_layer.visible = false
	label.visible_characters = 0

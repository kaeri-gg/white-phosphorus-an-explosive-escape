class_name InGameDialog
extends Area2D

static var _active: InGameDialog = null

@export_multiline var dialog_text: String = "Press [space] to jump."
@export var chars_per_second: float = 10.0
@export var display_seconds: float = 3.0

@onready var canvas_layer: CanvasLayer = %DialogCanvasLayer
@onready var label: Label = %DialogLabel

var _typing_tween: Tween
var _has_shown: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	label.text = dialog_text
	label.visible_characters = 0
	canvas_layer.visible = false

func _on_body_entered(body: Node) -> void:
	if _has_shown or body is not Player:
		return
	_has_shown = true

	if _active and is_instance_valid(_active) and _active != self:
		_active._hide()
	_active = self

	_show_and_type()

func _show_and_type() -> void:
	label.text = dialog_text
	label.visible_characters = 0
	canvas_layer.visible = true

	var total_chars: int = dialog_text.length()
	if total_chars > 0:
		var typing_duration: float = max(0.05, float(total_chars) / max(1.0, chars_per_second))
		_typing_tween = create_tween()
		_typing_tween.tween_property(label, "visible_characters", total_chars, typing_duration)

	await get_tree().create_timer(display_seconds).timeout
	if _active == self:
		_hide()

func _hide() -> void:
	if _typing_tween:
		_typing_tween.kill()
		_typing_tween = null
	canvas_layer.visible = false
	label.visible_characters = 0
	if _active == self:
		_active = null

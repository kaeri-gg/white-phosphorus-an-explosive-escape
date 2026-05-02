class_name TutorialDialog
extends Area2D

# A world-space tutorial-bubble trigger.
#
# When the Player enters this Area2D, a Label appears above the player's head,
# types the configured text out character-by-character, and disappears after
# `display_seconds`. The bubble follows the player as they move, until the
# hide timer fires.
#
# Re-entering the trigger while the bubble is still on screen restarts the
# typing animation and resets the hide timer.

## The text typed into the bubble when the player enters the trigger.
@export_multiline var dialog_text: String = "Watch out for the fire!"

## How fast the text types out, in characters per second.
@export var chars_per_second: float = 30.0

## How long (in seconds) the bubble stays on screen, total — counted from
## the moment the player enters the trigger, not from when typing finishes.
@export var display_seconds: float = 3.0

## Offset (relative to the player's origin) where the bubble's center sits.
## Negative Y is upward — the default is 100 px above the player's root.
@export var bubble_offset: Vector2 = Vector2(0, -100)

@onready var bubble_label: Label = %BubbleLabel
@onready var hide_timer: Timer = %HideTimer

var _typing_tween: Tween
var _current_player: Player

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	hide_timer.timeout.connect(_hide)

	bubble_label.top_level = true
	bubble_label.visible = false
	bubble_label.visible_characters = 0
	bubble_label.text = dialog_text

	set_process(false)

func _process(_delta: float) -> void:
	if _current_player == null or not is_instance_valid(_current_player):
		return
	# Center the label above the player by subtracting half of its measured size.
	var anchor: Vector2 = _current_player.global_position + bubble_offset
	bubble_label.global_position = anchor - bubble_label.size * 0.5

func _on_body_entered(body: Node) -> void:
	if body is Player:
		_current_player = body
		_show_and_type()

func _show_and_type() -> void:
	if _typing_tween:
		_typing_tween.kill()

	bubble_label.text = dialog_text
	bubble_label.visible_characters = 0
	bubble_label.visible = true
	set_process(true)

	var total_chars: int = dialog_text.length()
	if total_chars > 0:
		var typing_duration: float = max(
			0.05,
			float(total_chars) / max(1.0, chars_per_second)
		)
		_typing_tween = create_tween()
		_typing_tween.tween_property(bubble_label, "visible_characters", total_chars, typing_duration)

	hide_timer.start(display_seconds)

func _hide() -> void:
	if _typing_tween:
		_typing_tween.kill()
		_typing_tween = null
	bubble_label.visible = false
	bubble_label.visible_characters = 0
	_current_player = null
	set_process(false)

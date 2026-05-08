class_name TutorialDialog
extends Area2D

static var _active: TutorialDialog = null

@export_multiline var dialog_text: String = "Watch out for the fire!"
@export var chars_per_second: float = 50.0
@export var display_seconds: float = 5.0
@export var bubble_offset: Vector2 = Vector2(0, -100)

@onready var bubble_anchor: Node2D = $BubbleAnchor
@onready var bubble_root: PanelContainer = $BubbleAnchor/PanelContainer
@onready var bubble_label: Label = %BubbleLabel
@onready var hide_timer: Timer = %HideTimer

var _typing_tween: Tween
var _current_player: Player
var _has_shown: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	hide_timer.timeout.connect(_hide)

	bubble_anchor.top_level = true
	bubble_anchor.visible = false
	bubble_label.text = dialog_text
	bubble_label.visible_characters = 0

	set_process(false)

func _process(_delta: float) -> void:
	if _current_player == null or not is_instance_valid(_current_player):
		return
	bubble_anchor.global_position = _current_player.global_position + bubble_offset
	bubble_root.position = -bubble_root.size * 0.5

func _on_body_entered(body: Node) -> void:
	if _has_shown or body is not Player:
		return
	_has_shown = true
	_current_player = body

	if _active and is_instance_valid(_active) and _active != self:
		_active._hide()
	_active = self

	_show_and_type()

func _show_and_type() -> void:
	if _typing_tween:
		_typing_tween.kill()

	bubble_label.text = dialog_text
	bubble_label.visible_characters = 0
	bubble_anchor.visible = true
	set_process(true)

	var total_chars: int = dialog_text.length()
	if total_chars > 0:
		var typing_duration: float = max(0.05, float(total_chars) / max(1.0, chars_per_second))
		_typing_tween = create_tween()
		_typing_tween.tween_property(bubble_label, "visible_characters", total_chars, typing_duration)

	hide_timer.start(display_seconds)

func _hide() -> void:
	if _typing_tween:
		_typing_tween.kill()
		_typing_tween = null
	bubble_anchor.visible = false
	bubble_label.visible_characters = 0
	_current_player = null
	set_process(false)
	if _active == self:
		_active = null

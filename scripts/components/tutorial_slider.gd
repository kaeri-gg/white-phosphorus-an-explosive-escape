class_name TutorialSlider
extends Control

const INSTRUCTIONS: Array[String] = [
	"Use [A] / [D] or the arrow keys to move left and right.",
	"Press [Space], [W], or the up arrow to jump.",
	"Press [E] near an object to interact with it.",
]

const DOT_ACTIVE := Color(0.27, 0.45, 0.85, 1.0)
const DOT_INACTIVE := Color(0.75, 0.75, 0.75, 1.0)

@onready var _gif_0: TextureRect = %GIF_0
@onready var _gif_1: TextureRect = %GIF_1
@onready var _gif_2: TextureRect = %GIF_2
@onready var _dot_0: ColorRect = %Dot0
@onready var _dot_1: ColorRect = %Dot1
@onready var _dot_2: ColorRect = %Dot2
@onready var instruction_label: Label = %InstructionLabel
@onready var prev_button: Button = %PrevButton
@onready var next_button: Button = %NextButton

var gif_frames: Array[TextureRect]
var dots: Array[ColorRect]
var _index: int = 0

func _ready() -> void:
	gif_frames = [_gif_0, _gif_1, _gif_2]
	dots = [_dot_0, _dot_1, _dot_2]
	prev_button.pressed.connect(_on_prev)
	next_button.pressed.connect(_on_next)
	prev_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	next_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	reset()

func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_LEFT:
			_on_prev()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_RIGHT:
			_on_next()
			get_viewport().set_input_as_handled()

func reset() -> void:
	_index = 0
	_update()

func _on_prev() -> void:
	if _index > 0:
		_index -= 1
		sound_manager.play("Click")
		_update()

func _on_next() -> void:
	if _index < gif_frames.size() - 1:
		_index += 1
		sound_manager.play("Click")
		_update()

func _update() -> void:
	for i in gif_frames.size():
		gif_frames[i].visible = i == _index
	for i in dots.size():
		dots[i].color = DOT_ACTIVE if i == _index else DOT_INACTIVE
	instruction_label.text = INSTRUCTIONS[_index]
	prev_button.modulate.a = 0.35 if _index == 0 else 1.0
	next_button.modulate.a = 0.35 if _index == gif_frames.size() - 1 else 1.0

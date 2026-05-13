class_name TutorialSlider
extends Control

const INSTRUCTIONS: Array[String] = [
	"Use [A] / [D] or the arrow keys to move left and right.",
	"Press [Space], [W], or the up arrow to jump. Press 2x for double-jump!",
	"Press [E] near water valve to interact with it.",
]

const DOT_ACTIVE := Color(0.27, 0.45, 0.85, 1.0)
const DOT_INACTIVE := Color(0.75, 0.75, 0.75, 1.0)

@onready var _gif_0: VideoStreamPlayer = %GIF_0
@onready var _gif_1: VideoStreamPlayer = %GIF_1
@onready var _gif_2: VideoStreamPlayer = %GIF_2
@onready var _dot_0: ColorRect = %Dot0
@onready var _dot_1: ColorRect = %Dot1
@onready var _dot_2: ColorRect = %Dot2
@onready var instruction_label: Label = %InstructionLabel
@onready var prev_button: HoverableButton = %PrevButton
@onready var next_button: HoverableButton = %NextButton

var gif_frames: Array[VideoStreamPlayer]
var dots: Array[ColorRect]
var _index: int = 0

func _ready() -> void:
	gif_frames = [_gif_0, _gif_1, _gif_2]
	dots = [_dot_0, _dot_1, _dot_2]
	prev_button.pressed.connect(_on_prev)
	next_button.pressed.connect(_on_next)
	reset()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_left"):
		_on_prev()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
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
		var is_active := i == _index
		gif_frames[i].visible = is_active
		if is_active:
			gif_frames[i].play()
		else:
			gif_frames[i].stop()
	for i in dots.size():
		dots[i].color = DOT_ACTIVE if i == _index else DOT_INACTIVE
	instruction_label.text = INSTRUCTIONS[_index]
	prev_button.modulate.a = 0.35 if _index == 0 else 1.0
	next_button.modulate.a = 0.35 if _index == gif_frames.size() - 1 else 1.0

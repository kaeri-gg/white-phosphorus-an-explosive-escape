@tool
extends TextureRect
class_name GlowRect

@export_group("Pulse")
## How many times per second the glow brightens and dims.
@export var pulse_speed: float = 1.5
## Alpha at the dimmest point of the pulse.
@export var pulse_min_alpha: float = 0.3
## Alpha at the brightest point of the pulse.
@export var pulse_max_alpha: float = 1.0

@export_group("Rise")
## How many pixels upward the glow drifts at peak brightness.
@export var rise_pixels: float = 12.0

var _tween: Tween
var _base_y: float

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_base_y = position.y
	_start_pulse()

func _start_pulse() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()

	modulate.a = pulse_min_alpha
	position.y = _base_y

	var half: float = 1.0 / max(pulse_speed, 0.01)
	_tween = create_tween().set_loops()
	_tween.tween_method(_set_pulse, 0.0, 1.0, half) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_method(_set_pulse, 1.0, 0.0, half) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _set_pulse(t: float) -> void:
	modulate.a = lerp(pulse_min_alpha, pulse_max_alpha, t)
	position.y = _base_y - rise_pixels * t

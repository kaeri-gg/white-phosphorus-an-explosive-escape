extends Control

## Floating virtual joystick.
## Shows a dim resting hint at the bottom-left, then teleports its base
## to the first touch inside the active zone, tracks that single finger,
## and drives Input actions with analog strength so
## `Input.get_axis(negative_action, positive_action)` returns [-1, 1].

enum ActiveSide { LEFT, RIGHT, ANY }

@export var negative_action: StringName = &"move_left"
@export var positive_action: StringName = &"move_right"
@export var active_side: ActiveSide = ActiveSide.LEFT
@export_range(20.0, 300.0) var base_radius: float = 90.0
@export_range(10.0, 200.0) var knob_radius: float = 45.0
@export_range(0.0, 0.9) var deadzone: float = 0.15
## Pixels from the top of the screen where joystick touches are ignored,
## so top-anchored UI (Home/Restart/Help) stays clickable.
@export var top_exclusion_height: float = 180.0
## Distance from the bottom-left corner where the resting hint sits.
@export var rest_padding: Vector2 = Vector2(140.0, 140.0)
## Alpha multiplier applied to base/knob colors when idle, so the hint
## reads as a suggestion rather than an active control.
@export_range(0.0, 1.0) var rest_alpha: float = 0.55
@export var base_color: Color = Color(1, 1, 1, 0.20)
@export var knob_color: Color = Color(1, 1, 1, 0.70)

var _touch_index: int = -1
var _base_pos: Vector2 = Vector2.ZERO
var _knob_pos: Vector2 = Vector2.ZERO
var _rest_pos: Vector2 = Vector2.ZERO
var _active: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_update_rest_pos)
	_update_rest_pos()


func _update_rest_pos() -> void:
	_rest_pos = Vector2(rest_padding.x, size.y - rest_padding.y)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob((event.position - global_position))
		get_viewport().set_input_as_handled()


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _active:
			return
		var local := (event.position - global_position)
		if not _in_active_zone(local):
			return
		_touch_index = event.index
		_active = true
		_base_pos = local
		_knob_pos = local
		_apply_strength(0.0)
		queue_redraw()
		get_viewport().set_input_as_handled()
	elif event.index == _touch_index:
		_release()


func _update_knob(local_pos: Vector2) -> void:
	var offset := local_pos - _base_pos
	if offset.length() > base_radius:
		offset = offset.normalized() * base_radius
	_knob_pos = _base_pos + offset
	_apply_strength(clampf(offset.x / base_radius, -1.0, 1.0))
	queue_redraw()


func _apply_strength(x: float) -> void:
	var magnitude := absf(x)
	if magnitude < deadzone:
		Input.action_release(positive_action)
		Input.action_release(negative_action)
		return
	var remapped := (magnitude - deadzone) / (1.0 - deadzone)
	if x > 0.0:
		Input.action_release(negative_action)
		Input.action_press(positive_action, remapped)
	else:
		Input.action_release(positive_action)
		Input.action_press(negative_action, remapped)


func _release() -> void:
	_active = false
	_touch_index = -1
	Input.action_release(positive_action)
	Input.action_release(negative_action)
	queue_redraw()


func _in_active_zone(local_pos: Vector2) -> bool:
	if local_pos.y < top_exclusion_height:
		return false
	match active_side:
		ActiveSide.LEFT:
			return local_pos.x < size.x * 0.5
		ActiveSide.RIGHT:
			return local_pos.x > size.x * 0.5
		_:
			return true


func _draw() -> void:
	if _active:
		draw_circle(_base_pos, base_radius, base_color)
		draw_arc(_base_pos, base_radius, 0.0, TAU, 48, Color(knob_color, 0.5), 2.0, true)
		draw_circle(_knob_pos, knob_radius, knob_color)
	else:
		var hint_base := Color(base_color, base_color.a * rest_alpha)
		var hint_ring := Color(knob_color, knob_color.a * rest_alpha * 0.6)
		var hint_nub := Color(knob_color, knob_color.a * rest_alpha)
		draw_circle(_rest_pos, base_radius, hint_base)
		draw_arc(_rest_pos, base_radius, 0.0, TAU, 48, hint_ring, 2.0, true)
		draw_circle(_rest_pos, knob_radius * 0.6, hint_nub)

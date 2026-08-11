class_name HoverableButton
extends Control

const MOBILE_SIZE := Vector2(110, 110)

## Enlarge this button to MOBILE_SIZE on touch devices. Turn off for buttons
## laid out inside a modal or other tight container where scaling would break
## the design (e.g. tutorial Next/Prev).
@export var scale_on_mobile: bool = true

signal pressed

var _inner_button: BaseButton

func _ready() -> void:
	if scale_on_mobile and _is_touch_device():
		custom_minimum_size = MOBILE_SIZE
		_expand_inner_margin_to_fill()

	_inner_button = _resolve_inner_button()
	if _inner_button == null:
		push_warning("%s: no BaseButton child found." % name)
		return

	_inner_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_inner_button.pressed.connect(_on_inner_pressed)
	_setup()

static func _is_touch_device() -> bool:
	return OS.has_feature("mobile") \
		or OS.has_feature("web_android") \
		or OS.has_feature("web_ios")

func _expand_inner_margin_to_fill() -> void:
	var margin := get_node_or_null("MarginContainer") as Control
	if margin == null:
		return
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_right = 0.0
	margin.offset_bottom = 0.0
	margin.add_theme_constant_override("margin_left", 0)
	margin.add_theme_constant_override("margin_right", 0)

## Override to do extra setup after the inner button is wired.
func _setup() -> void:
	pass

## Override to point at a specific inner button. Default: first BaseButton in the subtree.
func _resolve_inner_button() -> BaseButton:
	return _find_base_button(self)

func _on_inner_pressed() -> void:
	pressed.emit()

static func _find_base_button(node: Node) -> BaseButton:
	for child in node.get_children():
		if child is BaseButton:
			return child as BaseButton
		var found := _find_base_button(child)
		if found != null:
			return found
	return null

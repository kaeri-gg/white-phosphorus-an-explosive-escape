class_name HoverableButton
extends Control

signal pressed

var _inner_button: BaseButton

func _ready() -> void:
	_inner_button = _resolve_inner_button()
	if _inner_button == null:
		push_warning("%s: no BaseButton child found." % name)
		return

	_inner_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_inner_button.pressed.connect(_on_inner_pressed)
	_setup()

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

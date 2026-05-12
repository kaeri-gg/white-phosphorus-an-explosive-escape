class_name HoverableButton
extends Control

signal pressed

var _inner_button: BaseButton
var _hovered: bool = false
var _held: bool = false

func _ready() -> void:
	_inner_button = _resolve_inner_button()
	if _inner_button == null:
		push_warning("%s: no BaseButton child found." % name)
		return

	_inner_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_inner_button.mouse_entered.connect(_on_mouse_entered)
	_inner_button.mouse_exited.connect(_on_mouse_exited)
	_inner_button.button_down.connect(_on_button_down)
	_inner_button.button_up.connect(_on_button_up)
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

func _on_mouse_entered() -> void:
	_hovered = true
	if not _held:
		modulate = UiConstants.HOVER_MODULATE

func _on_mouse_exited() -> void:
	_hovered = false
	if not _held:
		modulate = UiConstants.NORMAL_MODULATE

func _on_button_down() -> void:
	_held = true
	modulate = UiConstants.PRESS_MODULATE

func _on_button_up() -> void:
	_held = false
	modulate = UiConstants.HOVER_MODULATE if _hovered else UiConstants.NORMAL_MODULATE

static func _find_base_button(node: Node) -> BaseButton:
	for child in node.get_children():
		if child is BaseButton:
			return child as BaseButton
		var found := _find_base_button(child)
		if found != null:
			return found
	return null

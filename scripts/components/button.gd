class_name ActionButton
extends HoverableButton

@export var custom_label_text: String = "Button label"
@export var theme_variation: String = ""
@export var enable_space_shortcut: bool = true
@export var texture: Texture2D
@export var tooltip: String = ""

func _setup() -> void:
	var button := _inner_button as TextureButton
	if button == null:
		return
	if not theme_variation.is_empty():
		button.theme_type_variation = theme_variation
	if texture:
		button.texture_normal = texture
	if enable_space_shortcut:
		var shortcut := Shortcut.new()
		var event := InputEventKey.new()
		event.physical_keycode = KEY_SPACE
		shortcut.events = [event]
		button.shortcut = shortcut
		button.shortcut_in_tooltip = false
	if not tooltip.is_empty():
		button.tooltip_text = tooltip

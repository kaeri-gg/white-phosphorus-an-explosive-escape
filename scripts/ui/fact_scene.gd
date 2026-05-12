class_name FactScene
extends Control

const HOVER_MODULATE := Color(1.15, 1.15, 1.15)
const PRESS_MODULATE := Color(0.85, 0.85, 0.85)
const NORMAL_MODULATE := Color(1.0, 1.0, 1.0)

@export_file("*.tscn") var next_scene_path: String = ""
@export var fade_duration: float = 0.6

var _next_hovered := false

func _ready() -> void:
	utils.fade_from_overlay(fade_duration)
	_wire_button("NextScreen", next_scene_path)
	var next_button: ActionButton = %NextScreen
	next_button.mouse_entered.connect(_on_next_mouse_entered)
	next_button.mouse_exited.connect(_on_next_mouse_exited)
	next_button.button_down.connect(_on_next_button_down)
	next_button.button_up.connect(_on_next_button_up)

func _on_next_mouse_entered() -> void:
	_next_hovered = true
	%NextScreen.modulate = HOVER_MODULATE

func _on_next_mouse_exited() -> void:
	_next_hovered = false
	%NextScreen.modulate = NORMAL_MODULATE

func _on_next_button_down() -> void:
	%NextScreen.modulate = PRESS_MODULATE

func _on_next_button_up() -> void:
	if _next_hovered:
		%NextScreen.modulate = HOVER_MODULATE
	else:
		%NextScreen.modulate = NORMAL_MODULATE

func _wire_button(unique_name: String, scene_path: String) -> void:
	var button: ActionButton = get_node_or_null("%" + unique_name)
	if not button:
		return
	if not button.pressed.is_connected(_change_scene.bind(scene_path)):
		button.pressed.connect(_change_scene.bind(scene_path))

func _change_scene(path: String) -> void:
	if path.is_empty():
		push_warning("%s is missing a scene path." % name)
		return

	var resolved_scene_path: String = ResourceUID.ensure_path(path)
	if resolved_scene_path.is_empty():
		push_warning("%s could not resolve scene path: %s" % [name, path])
		return

	sound_manager.play("EnterGame")
	await utils.fade_to_white(self, fade_duration)
	get_tree().change_scene_to_file(resolved_scene_path)

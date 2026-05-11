class_name HomeButton
extends Control

@onready var home_button: TextureButton = %HomeButton
@export_file("*.tscn") var target_scene_path: String = "uid://4ht2ox1qqc7q"
@export var fade_duration: float = 0.6
var hovered = false

func _ready() -> void:
	if home_button and not home_button.pressed.is_connected(return_home):
		home_button.pressed.connect(return_home)
	home_button.mouse_entered.connect(_on_mouse_entered)
	home_button.mouse_exited.connect(_on_mouse_exited)
	home_button.button_down.connect(_on_button_down)
	home_button.button_up.connect(_on_button_up)

func _on_mouse_entered() -> void:
	hovered = true
	modulate.a = 0.8

func _on_mouse_exited() -> void:
	hovered = false
	modulate.a = 1.0

func _on_button_down() -> void:
	modulate.a = 0.5

func _on_button_up() -> void:
	if hovered:
		modulate.a = 0.8
	else:
		modulate.a = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if !(event is InputEventKey):
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode != KEY_B:
		return

	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
	return_home()

func return_home() -> void:
	sound_manager.play("Click")
	await utils.fade_to_white(get_tree().current_scene, fade_duration)
	get_tree().change_scene_to_file(target_scene_path)

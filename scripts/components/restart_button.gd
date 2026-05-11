class_name RestartButton
extends Control

@onready var restart_button: TextureButton = %RestartButton
var hovered = false

func _ready() -> void:
	if restart_button and not restart_button.pressed.is_connected(restart_level):
		restart_button.pressed.connect(restart_level)
	restart_button.mouse_entered.connect(_on_mouse_entered)
	restart_button.mouse_exited.connect(_on_mouse_exited)
	restart_button.button_down.connect(_on_button_down)
	restart_button.button_up.connect(_on_button_up)

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

	if key_event.keycode != KEY_R:
		return

	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
	restart_level()

func restart_level() -> void:
	sound_manager.play("Click")
	get_tree().reload_current_scene()

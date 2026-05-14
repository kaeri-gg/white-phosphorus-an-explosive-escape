class_name FactScene
extends Control

@export_file("*.tscn") var next_scene_path: String = ""
@export var fade_duration: float = UiConstants.DEFAULT_FADE_DURATION

var _comics: Array[Comic] = []
var _next_screen: ActionButton

func _ready() -> void:
	utils.fade_from_overlay(fade_duration)
	_wire_button("NextScreen", next_scene_path)
	_next_screen = get_node_or_null("%NextScreen")
	if _next_screen:
		_next_screen.visible = false
	_start_comic_sequence()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		for comic in _comics:
			if not comic.visible:
				comic.fade_in()
				_check_sequence_complete()
				break

func _start_comic_sequence() -> void:
	for child in get_children():
		if child is Comic:
			_comics.append(child)
	_comics.sort_custom(func(a: Comic, b: Comic) -> bool: return a.sequence < b.sequence)
	for comic in _comics:
		get_tree().create_timer(comic.duration).timeout.connect(func() -> void:
			comic.fade_in()
			_check_sequence_complete()
		)

func _check_sequence_complete() -> void:
	for comic in _comics:
		if not comic.visible:
			return
	if _next_screen:
		_next_screen.visible = true

func _wire_button(unique_name: String, scene_path: String) -> void:
	var button: ActionButton = get_node_or_null("%" + unique_name)
	if not button:
		return
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
